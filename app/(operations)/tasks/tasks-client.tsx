"use client";

import Link from "next/link";
import { ArrowRight, Check, CheckCircle2, CircleDashed, Clock3, TriangleAlert } from "lucide-react";
import { useMemo, useRef, useState } from "react";
import { DetailDrawer } from "../_components/detail-drawer";
import { assignedTasks, matters, PROTOTYPE_DATE } from "../_lib/data";
import type { Task, TaskState } from "../_lib/types";

type TaskFilter = "open" | "attention" | "review" | "completed";

const filterLabels: Record<TaskFilter, string> = {
  open: "All open",
  attention: "Blocked & waiting",
  review: "Under review",
  completed: "Completed",
};

function taskTone(state: TaskState) {
  if (state === "Blocked") return "critical";
  if (state === "Waiting" || state === "Under Review") return "warning";
  if (state === "Completed") return "success";
  return "info";
}

export function TasksClient() {
  const [filter, setFilter] = useState<TaskFilter>("open");
  const [completedIds, setCompletedIds] = useState<string[]>([]);
  const [selectedTask, setSelectedTask] = useState<Task | null>(null);
  const returnFocusRef = useRef<HTMLElement | null>(null);

  const tasks = useMemo(
    () => assignedTasks.map((task) => completedIds.includes(task.id) ? { ...task, state: "Completed" as const } : task),
    [completedIds],
  );

  const filteredTasks = tasks.filter((task) => {
    if (filter === "completed") return task.state === "Completed";
    if (filter === "attention") return task.state === "Blocked" || task.state === "Waiting";
    if (filter === "review") return task.state === "Under Review";
    return task.state !== "Completed";
  });

  const attentionCount = tasks.filter((task) => task.state === "Blocked" || task.state === "Waiting").length;
  const todayCount = tasks.filter((task) => task.dueLabel === "Today" || task.dueLabel === "Overdue").length;

  function openTask(task: Task, trigger: HTMLElement) {
    returnFocusRef.current = trigger;
    setSelectedTask(task);
  }

  function toggleComplete(taskId: string) {
    setCompletedIds((current) => current.includes(taskId) ? current.filter((id) => id !== taskId) : [...current, taskId]);
  }

  return (
    <>
      <header className="ops-page-heading">
        <div>
          <p className="ops-page-date">Tuesday, {PROTOTYPE_DATE}</p>
          <h1>My tasks</h1>
          <p>A personal work queue ordered by urgency, then controlling date.</p>
        </div>
        <Link href="/deadlines" className="ops-secondary-button">
          Review deadlines <ArrowRight aria-hidden="true" size={17} />
        </Link>
      </header>

      <section className="ops-status-ledger" aria-label="Task summary">
        <div className="has-critical"><span>Due now</span><strong>{todayCount}</strong><small>Includes one overdue task</small></div>
        <div><span>Blocked or waiting</span><strong>{attentionCount}</strong><small>External action required</small></div>
        <div><span>Under review</span><strong>{tasks.filter((task) => task.state === "Under Review").length}</strong><small>Attorney decision pending</small></div>
        <div><span>Completed today</span><strong>{completedIds.length}</strong><small>Local prototype state</small></div>
      </section>

      <section className="ops-panel" aria-labelledby="task-queue-title">
        <header className="ops-panel-heading">
          <div><h2 id="task-queue-title">Task queue</h2><p>Assigned to Jordan Lee across active matters.</p></div>
          <span className="ops-count-label">{filteredTasks.length} shown</span>
        </header>
        <div className="ops-tabs" role="tablist" aria-label="Filter tasks">
          {(Object.keys(filterLabels) as TaskFilter[]).map((key) => (
            <button type="button" role="tab" aria-selected={filter === key} className={filter === key ? "is-selected" : ""} onClick={() => setFilter(key)} key={key}>
              {filterLabels[key]}
            </button>
          ))}
        </div>

        {filteredTasks.length ? (
          <div className="ops-work-list">
            {filteredTasks.map((task) => {
              const matter = matters.find((entry) => entry.id === task.matterId);
              const tone = taskTone(task.state);
              return (
                <article className={`ops-work-row is-${tone}`} key={task.id}>
                  <button
                    type="button"
                    className="ops-task-check"
                    aria-label={task.state === "Completed" ? `Reopen ${task.title}` : `Mark ${task.title} complete`}
                    aria-pressed={task.state === "Completed"}
                    onClick={() => toggleComplete(task.id)}
                  >
                    {task.state === "Completed" ? <Check aria-hidden="true" size={17} /> : <span aria-hidden="true" />}
                  </button>
                  <div className="ops-work-primary">
                    <div className="ops-work-meta">
                      <span className={`ops-status-text is-${tone}`}>{task.state}</span>
                      <span>{task.type} task</span>
                    </div>
                    <h3>{task.title}</h3>
                    <p>{matter?.reference} · {matter?.client} · {matter?.property}</p>
                  </div>
                  <div className="ops-work-due">
                    <span>Due</span>
                    <strong className={task.dueLabel === "Overdue" ? "is-overdue" : ""}>{task.dueLabel}</strong>
                  </div>
                  <button type="button" className="ops-row-action" aria-label={`View ${task.title}`} onClick={(event) => openTask(task, event.currentTarget)}>
                    <ArrowRight aria-hidden="true" size={17} />
                  </button>
                </article>
              );
            })}
          </div>
        ) : (
          <div className="ops-inline-empty" aria-live="polite">
            <CheckCircle2 aria-hidden="true" size={24} />
            <div><h3>No tasks in this view</h3><p>Choose another filter to return to the active queue.</p></div>
          </div>
        )}
      </section>

      <DetailDrawer title={selectedTask?.title ?? "Task details"} description={selectedTask?.dueLabel} open={Boolean(selectedTask)} onClose={() => setSelectedTask(null)} returnFocusRef={returnFocusRef}>
        {selectedTask ? (
          <div className="ops-detail-stack">
            <div className={`ops-callout is-${taskTone(selectedTask.state)}`}>
              {selectedTask.state === "Blocked" ? <TriangleAlert aria-hidden="true" size={19} /> : selectedTask.state === "Under Review" ? <Clock3 aria-hidden="true" size={19} /> : <CircleDashed aria-hidden="true" size={19} />}
              <p>{selectedTask.state === "Blocked" ? "This task cannot advance until the lender confirms the requested extension." : selectedTask.state === "Under Review" ? "The related submission is waiting for Attorney review before Operations can record the outcome." : "This task remains in Jordan Lee's active work queue."}</p>
            </div>
            <dl className="ops-detail-list">
              <div><dt>Matter</dt><dd>{matters.find((matter) => matter.id === selectedTask.matterId)?.reference}</dd></div>
              <div><dt>State</dt><dd>{selectedTask.state}</dd></div>
              <div><dt>Owner</dt><dd>{selectedTask.owner}</dd></div>
              <div><dt>Due</dt><dd>{selectedTask.dueLabel}</dd></div>
            </dl>
            <Link href={`/matters/${selectedTask.matterId}`} className="ops-primary-button">Open matter <ArrowRight aria-hidden="true" size={17} /></Link>
          </div>
        ) : null}
      </DetailDrawer>
    </>
  );
}
