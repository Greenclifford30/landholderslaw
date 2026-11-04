"use client";

import Link from "next/link";
import {
  ArrowDownAZ,
  ArrowRight,
  CalendarClock,
  FilterX,
  Search,
  SlidersHorizontal,
} from "lucide-react";
import { useMemo, useRef, useState } from "react";
import { DetailDrawer } from "../_components/detail-drawer";
import { matters } from "../_lib/data";
import type { MatterStatus, MatterSummary, MatterType } from "../_lib/types";

type SortOption = "deadline" | "priority" | "closing";

const statusOptions: Array<MatterStatus | "All"> = [
  "All",
  "Active",
  "Closing Scheduled",
  "Post-Closing Pending",
  "On Hold",
];

const priorityOrder = { Critical: 0, High: 1, Normal: 2 } as const;

export function MattersClient() {
  const [query, setQuery] = useState("");
  const [type, setType] = useState<MatterType | "All">("All");
  const [status, setStatus] = useState<MatterStatus | "All">("All");
  const [owner, setOwner] = useState("All");
  const [sort, setSort] = useState<SortOption>("deadline");
  const [selectedMatter, setSelectedMatter] = useState<MatterSummary | null>(null);
  const returnFocusRef = useRef<HTMLElement | null>(null);

  const filteredMatters = useMemo(() => {
    const normalizedQuery = query.trim().toLowerCase();
    return matters
      .filter((matter) => {
        const matchesQuery = !normalizedQuery ||
          [matter.reference, matter.client, matter.property, matter.municipality]
            .join(" ")
            .toLowerCase()
            .includes(normalizedQuery);
        const matchesType = type === "All" || matter.type === type;
        const matchesStatus = status === "All" || matter.status === status;
        const matchesOwner = owner === "All" ||
          matter.assignedAttorney === owner ||
          matter.assignedOperations === owner;
        return matchesQuery && matchesType && matchesStatus && matchesOwner;
      })
      .sort((a, b) => {
        if (sort === "closing") return a.closingDate.localeCompare(b.closingDate);
        if (sort === "priority") {
          return priorityOrder[a.priority] - priorityOrder[b.priority] ||
            a.nextDeadline.date.localeCompare(b.nextDeadline.date);
        }
        return a.nextDeadline.date.localeCompare(b.nextDeadline.date) ||
          priorityOrder[a.priority] - priorityOrder[b.priority];
      });
  }, [owner, query, sort, status, type]);

  const hasFilters = Boolean(query || type !== "All" || status !== "All" || owner !== "All");

  function resetFilters() {
    setQuery("");
    setType("All");
    setStatus("All");
    setOwner("All");
  }

  function openPreview(matter: MatterSummary, trigger: HTMLElement) {
    returnFocusRef.current = trigger;
    setSelectedMatter(matter);
  }

  return (
    <>
      <header className="ops-page-heading">
        <div>
          <h1>Matters</h1>
          <p>Locate a transaction by client, property, status, or next controlling date.</p>
        </div>
        <div className="ops-deferred-action">
          <button type="button" className="ops-primary-button" disabled>
            New matter
          </button>
          <span>Intake is not included in this prototype.</span>
        </div>
      </header>

      <section className="ops-matter-controls" aria-label="Matter filters">
        <div className="ops-local-search">
          <Search aria-hidden="true" size={18} />
          <label className="ops-visually-hidden" htmlFor="matter-search">Search matters</label>
          <input
            id="matter-search"
            type="search"
            value={query}
            placeholder="Search reference, client, property, or municipality"
            onChange={(event) => setQuery(event.target.value)}
          />
        </div>
        <label className="ops-filter-field">
          <span>Type</span>
          <select value={type} onChange={(event) => setType(event.target.value as MatterType | "All")}>
            <option>All</option>
            <option>Buyer</option>
            <option>Seller</option>
          </select>
        </label>
        <label className="ops-filter-field">
          <span>Status</span>
          <select value={status} onChange={(event) => setStatus(event.target.value as MatterStatus | "All")}>
            {statusOptions.map((option) => <option key={option}>{option}</option>)}
          </select>
        </label>
        <label className="ops-filter-field">
          <span>Owner</span>
          <select value={owner} onChange={(event) => setOwner(event.target.value)}>
            <option>All</option>
            <option>Jordan Lee</option>
            <option>Ted M. Word</option>
          </select>
        </label>
      </section>

      <div className="ops-directory-toolbar">
        <div>
          <SlidersHorizontal aria-hidden="true" size={16} />
          <strong>{filteredMatters.length}</strong> of {matters.length} fictional matters
        </div>
        <div>
          {hasFilters ? (
            <button type="button" className="ops-text-button" onClick={resetFilters}>
              <FilterX aria-hidden="true" size={16} /> Clear filters
            </button>
          ) : null}
          <label className="ops-sort-field">
            <ArrowDownAZ aria-hidden="true" size={16} />
            <span>Sort</span>
            <select value={sort} onChange={(event) => setSort(event.target.value as SortOption)}>
              <option value="deadline">Next deadline</option>
              <option value="priority">Attention priority</option>
              <option value="closing">Closing date</option>
            </select>
          </label>
        </div>
      </div>

      {filteredMatters.length ? (
        <div className="ops-matter-table-wrap">
          <table className="ops-matter-table">
            <caption className="ops-visually-hidden">Fictional Buyer and Seller matter directory</caption>
            <thead>
              <tr>
                <th scope="col">Deadline spine</th>
                <th scope="col">Matter / client</th>
                <th scope="col">Property</th>
                <th scope="col">Status</th>
                <th scope="col">Next action</th>
                <th scope="col">Closing</th>
                <th scope="col"><span className="ops-visually-hidden">Actions</span></th>
              </tr>
            </thead>
            <tbody>
              {filteredMatters.map((matter) => (
                <tr key={matter.id}>
                  <td data-label="Next deadline" className="ops-directory-date-cell">
                    <span className={`ops-directory-date is-${matter.nextDeadline.state.toLowerCase().replaceAll(" ", "-")}`}>
                      <CalendarClock aria-hidden="true" size={14} />
                      {matter.nextDeadline.dateLabel}
                    </span>
                    <small>{matter.nextDeadline.title}</small>
                  </td>
                  <td data-label="Matter / client">
                    <Link href={`/matters/${matter.id}`}>{matter.reference}</Link>
                    <span>{matter.client} · {matter.type}</span>
                  </td>
                  <td data-label="Property">
                    <strong>{matter.property}</strong>
                    <span>{matter.municipality}, Illinois</span>
                  </td>
                  <td data-label="Status">
                    <span className={`ops-status-badge is-${matter.status.toLowerCase().replaceAll(" ", "-")}`}>
                      {matter.status}
                    </span>
                    {matter.blockerCount ? <small>{matter.blockerCount} blocker</small> : null}
                  </td>
                  <td data-label="Next action">{matter.nextAction}</td>
                  <td data-label="Closing">{matter.closingDateLabel}</td>
                  <td>
                    <button
                      type="button"
                      className="ops-row-action"
                      aria-label={`Preview ${matter.reference}`}
                      onClick={(event) => openPreview(matter, event.currentTarget)}
                    >
                      <ArrowRight aria-hidden="true" size={17} />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        <section className="ops-empty-state" aria-live="polite">
          <Search aria-hidden="true" size={25} />
          <h2>No matters match these filters</h2>
          <p>Clear the filters or broaden the search to return to the fictional directory.</p>
          <button type="button" className="ops-secondary-button" onClick={resetFilters}>
            Clear all filters
          </button>
        </section>
      )}

      <DetailDrawer
        title={selectedMatter?.reference ?? "Matter preview"}
        description={selectedMatter ? `${selectedMatter.client} · ${selectedMatter.type}` : undefined}
        open={Boolean(selectedMatter)}
        onClose={() => setSelectedMatter(null)}
        returnFocusRef={returnFocusRef}
      >
        {selectedMatter ? (
          <div className="ops-detail-stack">
            <div className="ops-preview-property">
              <span>Property</span>
              <strong>{selectedMatter.property}</strong>
              <p>{selectedMatter.municipality}, Illinois</p>
            </div>
            <dl className="ops-detail-list">
              <div><dt>Status</dt><dd>{selectedMatter.status}</dd></div>
              <div><dt>Next action</dt><dd>{selectedMatter.nextAction}</dd></div>
              <div><dt>Next deadline</dt><dd>{selectedMatter.nextDeadline.title} · {selectedMatter.nextDeadline.dateLabel}</dd></div>
              <div><dt>Attorney</dt><dd>{selectedMatter.assignedAttorney}</dd></div>
              <div><dt>Operations</dt><dd>{selectedMatter.assignedOperations}</dd></div>
            </dl>
            <Link href={`/matters/${selectedMatter.id}`} className="ops-primary-button">
              Open matter <ArrowRight aria-hidden="true" size={17} />
            </Link>
          </div>
        ) : null}
      </DetailDrawer>
    </>
  );
}

