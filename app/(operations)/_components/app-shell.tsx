"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  Bell,
  CalendarClock,
  ChevronRight,
  ClipboardCheck,
  FileCheck2,
  LayoutDashboard,
  Menu,
  Search,
  Settings,
  ShieldCheck,
  UsersRound,
  X,
} from "lucide-react";
import { useMemo, useRef, useState } from "react";
import { matters, notifications } from "../_lib/data";
import { DetailDrawer } from "./detail-drawer";

const navigation = [
  { label: "Dashboard", href: "/dashboard", icon: LayoutDashboard, enabled: true },
  { label: "Matters", href: "/matters", icon: FileCheck2, enabled: true },
  { label: "My Tasks", href: "/tasks", icon: ClipboardCheck, enabled: true },
  { label: "Approvals", href: "/approvals", icon: ShieldCheck, enabled: true },
  { label: "Deadlines", href: "/deadlines", icon: CalendarClock, enabled: true },
  { label: "Settings", href: "/settings", icon: Settings, enabled: true },
] as const;

export function AppShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const [mobileOpen, setMobileOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");
  const [searchOpen, setSearchOpen] = useState(false);
  const [notificationsOpen, setNotificationsOpen] = useState(false);
  const notificationButtonRef = useRef<HTMLButtonElement>(null);

  const searchResults = useMemo(() => {
    const query = searchQuery.trim().toLowerCase();
    if (!query) return [];
    return matters
      .filter((matter) =>
        [matter.reference, matter.client, matter.property, matter.municipality]
          .join(" ")
          .toLowerCase()
          .includes(query),
      )
      .slice(0, 5);
  }, [searchQuery]);

  function isActive(href: string) {
    if (href === "/dashboard") return pathname === href;
    return pathname === href || pathname.startsWith(`${href}/`);
  }

  return (
    <div className="ops-app">
      <a className="ops-skip-link" href="#ops-main">
        Skip to main content
      </a>

      <aside className={`ops-sidebar ${mobileOpen ? "is-open" : ""}`} aria-label="Primary navigation">
        <div className="ops-brand">
          <div className="ops-brand-mark" aria-hidden="true">
            <span />
          </div>
          <div>
            <strong>Landholders Law</strong>
            <span>Transaction operations</span>
          </div>
          <button
            type="button"
            className="ops-sidebar-close"
            onClick={() => setMobileOpen(false)}
            aria-label="Close navigation"
          >
            <X aria-hidden="true" size={20} />
          </button>
        </div>

        <nav className="ops-nav">
          {navigation.map((item) => {
            const Icon = item.icon;
            if (!item.enabled) {
              return (
                <span className="ops-nav-item is-disabled" aria-disabled="true" key={item.label}>
                  <Icon aria-hidden="true" size={19} />
                  <span>{item.label}</span>
                  <small>Not mocked</small>
                </span>
              );
            }
            return (
              <Link
                className={`ops-nav-item ${isActive(item.href) ? "is-active" : ""}`}
                href={item.href}
                aria-current={isActive(item.href) ? "page" : undefined}
                onClick={() => setMobileOpen(false)}
                key={item.label}
              >
                <Icon aria-hidden="true" size={19} />
                <span>{item.label}</span>
              </Link>
            );
          })}
        </nav>

        <div className="ops-sidebar-footer">
          <span className="ops-role-icon" aria-hidden="true">
            <UsersRound size={18} />
          </span>
          <div>
            <strong>Jordan Lee</strong>
            <span>Operations</span>
          </div>
        </div>
      </aside>

      {mobileOpen ? (
        <button
          type="button"
          className="ops-mobile-scrim"
          aria-label="Close navigation"
          onClick={() => setMobileOpen(false)}
        />
      ) : null}

      <div className="ops-workspace">
        <header className="ops-topbar">
          <button
            type="button"
            className="ops-menu-button"
            aria-label="Open navigation"
            aria-expanded={mobileOpen}
            onClick={() => setMobileOpen(true)}
          >
            <Menu aria-hidden="true" size={21} />
          </button>

          <div className="ops-global-search">
            <Search aria-hidden="true" size={18} />
            <label className="ops-visually-hidden" htmlFor="global-matter-search">
              Search matters
            </label>
            <input
              id="global-matter-search"
              type="search"
              value={searchQuery}
              placeholder="Search client, property, or matter reference"
              onFocus={() => setSearchOpen(true)}
              onChange={(event) => {
                setSearchQuery(event.target.value);
                setSearchOpen(true);
              }}
              onKeyDown={(event) => {
                if (event.key === "Escape") setSearchOpen(false);
              }}
            />
            {searchOpen && searchQuery ? (
              <div className="ops-search-results" role="listbox" aria-label="Matter search results">
                {searchResults.length ? (
                  searchResults.map((matter) => (
                    <Link
                      href={`/matters/${matter.id}`}
                      className="ops-search-result"
                      key={matter.id}
                      onClick={() => {
                        setSearchOpen(false);
                        setSearchQuery("");
                      }}
                    >
                      <span>
                        <strong>{matter.reference}</strong>
                        <small>{matter.client}</small>
                      </span>
                      <span>
                        {matter.property}
                        <ChevronRight aria-hidden="true" size={16} />
                      </span>
                    </Link>
                  ))
                ) : (
                  <p className="ops-search-empty">No fictional matters match “{searchQuery}”.</p>
                )}
              </div>
            ) : null}
          </div>

          <div className="ops-topbar-actions">
            <span className="ops-prototype-label">Prototype · fictional data</span>
            <button
              ref={notificationButtonRef}
              type="button"
              className="ops-icon-button ops-notification-button"
              aria-label="Open 3 notifications"
              onClick={() => setNotificationsOpen(true)}
            >
              <Bell aria-hidden="true" size={20} />
              <span>3</span>
            </button>
          </div>
        </header>

        <main id="ops-main" className="ops-main" tabIndex={-1}>
          {children}
        </main>
      </div>

      <DetailDrawer
        title="Notifications"
        description="Actionable updates for Operations"
        open={notificationsOpen}
        onClose={() => setNotificationsOpen(false)}
        returnFocusRef={notificationButtonRef}
      >
        <div className="ops-notification-list">
          {notifications.map((notification, index) => (
            <article key={notification.id} className={index === 0 ? "is-unread" : ""}>
              <div>
                <strong>{notification.title}</strong>
                <p>{notification.detail}</p>
              </div>
              <time>{notification.time}</time>
            </article>
          ))}
        </div>
      </DetailDrawer>
    </div>
  );
}

