// wide-chrome.jsx — chrome for the landscape TaskMaestro layout.
// Sidebar (Direction 1), NavRail + RailAreasDrawer (Direction 2),
// SprintBanner, ListAppBar, RightPaneEmpty.
// All chrome uses the established TaskMaestro brand-blue, the active dark
// pill, and Open Sans — exactly matching the phone screen tokens.

const { AREA_COLORS } = window.TMHelpers;

// ------- icons (single source of truth for wide-screen chrome) -------
const IconStrokeProps = {
  fill: 'none', stroke: 'currentColor', strokeWidth: 1.8,
  strokeLinecap: 'round', strokeLinejoin: 'round',
};

const Icon = ({ name, size = 20 }) => {
  const s = IconStrokeProps;
  switch (name) {
    case 'plan': return (<svg width={size} height={size} viewBox="0 0 24 24"><rect x="3.5" y="5" width="17" height="15" rx="2" {...s}/><path d="M3.5 9.5h17M8 3v4M16 3v4M7.5 13.5h2M11 13.5h2M14.5 13.5h2M7.5 16.5h2M11 16.5h2" {...s}/></svg>);
    case 'tasks': return (<svg width={size} height={size} viewBox="0 0 24 24"><rect x="3" y="4.5" width="13" height="3.6" rx="0.8" {...s}/><rect x="3" y="10.2" width="13" height="3.6" rx="0.8" {...s}/><rect x="3" y="15.9" width="13" height="3.6" rx="0.8" {...s}/><path d="M19.5 5.7h.5M19.5 11.4h.5M19.5 17.1h.5" {...s}/></svg>);
    case 'family': return (<svg width={size} height={size} viewBox="0 0 24 24"><circle cx="8.5" cy="8" r="3" {...s}/><circle cx="16" cy="9" r="2.5" {...s}/><path d="M3 19c.6-3 2.7-4.5 5.5-4.5S13.4 16 14 19" {...s}/><path d="M14.5 19c.4-2.4 2-3.6 4-3.6S22.1 16.6 22.5 19" {...s}/></svg>);
    case 'stats': return (<svg width={size} height={size} viewBox="0 0 24 24"><path d="M4 19h17" {...s}/><rect x="6" y="11" width="3" height="6" rx="0.5" {...s}/><rect x="11" y="7" width="3" height="10" rx="0.5" {...s}/><rect x="16" y="13" width="3" height="4" rx="0.5" {...s}/></svg>);
    case 'areas': return (<svg width={size} height={size} viewBox="0 0 24 24"><circle cx="7" cy="7" r="3" {...s}/><circle cx="17" cy="7" r="3" {...s}/><circle cx="7" cy="17" r="3" {...s}/><circle cx="17" cy="17" r="3" {...s}/></svg>);
    case 'sprint': return (<svg width={size} height={size} viewBox="0 0 24 24"><path d="M4 14l5-5 4 4 7-7" {...s}/><path d="M16 6h4v4" {...s}/></svg>);
    case 'goals': return (<svg width={size} height={size} viewBox="0 0 24 24"><circle cx="12" cy="12" r="8" {...s}/><circle cx="12" cy="12" r="4" {...s}/><circle cx="12" cy="12" r="1" fill="currentColor" stroke="none"/></svg>);
    case 'project': return (<svg width={size} height={size} viewBox="0 0 24 24"><path d="M3.5 7.5l8.5-4 8.5 4M3.5 7.5v9l8.5 4 8.5-4v-9M3.5 7.5l8.5 4M12 11.5v9M20.5 7.5L12 11.5" {...s}/></svg>);
    case 'month': return (<svg width={size} height={size} viewBox="0 0 24 24"><rect x="3" y="5" width="18" height="16" rx="2" {...s}/><path d="M3 10h18M8 3v4M16 3v4" {...s}/></svg>);
    case 'search': return (<svg width={size} height={size} viewBox="0 0 24 24"><circle cx="11" cy="11" r="6.5" {...s}/><path d="M20 20l-4.5-4.5" {...s}/></svg>);
    case 'filter': return (<svg width={size} height={size} viewBox="0 0 24 24"><path d="M3.5 6h17l-7 8v5l-3 1.5v-6.5l-7-8z" {...s}/></svg>);
    case 'plus': return (<svg width={size} height={size} viewBox="0 0 24 24"><path d="M12 5v14M5 12h14" {...s}/></svg>);
    case 'menu': return (<svg width={size} height={size} viewBox="0 0 24 24"><path d="M4 6h16M4 12h16M4 18h16" {...s}/></svg>);
    case 'chev-l': return (<svg width={size} height={size} viewBox="0 0 24 24"><path d="M15 18l-6-6 6-6" {...s}/></svg>);
    case 'chev-r': return (<svg width={size} height={size} viewBox="0 0 24 24"><path d="M9 6l6 6-6 6" {...s}/></svg>);
    case 'x': return (<svg width={size} height={size} viewBox="0 0 24 24"><path d="M6 6l12 12M18 6L6 18" {...s}/></svg>);
    case 'sort': return (<svg width={size} height={size} viewBox="0 0 24 24"><path d="M7 4v16M3 8l4-4 4 4M17 20V4M13 16l4 4 4-4" {...s}/></svg>);
    case 'sliders': return (<svg width={size} height={size} viewBox="0 0 24 24"><path d="M4 6h12M20 6h0M4 12h6M14 12h6M4 18h10M18 18h2" {...s}/><circle cx="17" cy="6" r="2" {...s}/><circle cx="12" cy="12" r="2" {...s}/><circle cx="16" cy="18" r="2" {...s}/></svg>);
    case 'trash': return (<svg width={size} height={size} viewBox="0 0 24 24"><path d="M4 7h16M9 7V4h6v3M6 7l1 13h10l1-13M10 11v6M14 11v6" {...s}/></svg>);
  }
  return null;
};

// ------- shared atoms -------
// Section header inside the sidebar. Used for un-collapsible groups.
const SidebarLabel = ({ children, action }) => (
  <div style={{
    display: 'flex', alignItems: 'center', gap: 6,
    padding: '14px 18px 6px 22px',
    fontSize: 10.5, fontWeight: 700,
    textTransform: 'uppercase', letterSpacing: 0.9,
    color: 'rgba(255,255,255,0.45)',
  }}>
    <span style={{ flex: 1 }}>{children}</span>
    {action && (
      <button style={{
        width: 22, height: 22, borderRadius: 6,
        background: 'transparent', border: 'none',
        color: 'rgba(255,255,255,0.55)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        cursor: 'pointer',
      }}>{action}</button>
    )}
  </div>
);

// Collapsible section header — click to toggle. Chevron rotates.
const CollapsibleSection = ({ label, action, count, defaultOpen = true, children }) => {
  const [open, setOpen] = React.useState(defaultOpen);
  return (
    <div>
      <div
        onClick={() => setOpen(o => !o)}
        style={{
          display: 'flex', alignItems: 'center', gap: 6,
          padding: '12px 16px 6px 18px',
          fontSize: 10.5, fontWeight: 700,
          textTransform: 'uppercase', letterSpacing: 0.9,
          color: 'rgba(255,255,255,0.55)',
          cursor: 'pointer',
          userSelect: 'none',
        }}
      >
        <span style={{
          display: 'inline-flex', width: 14, justifyContent: 'center',
          color: 'rgba(255,255,255,0.4)',
          transition: 'transform 150ms',
          transform: open ? 'rotate(90deg)' : 'rotate(0deg)',
        }}>
          <svg width="9" height="9" viewBox="0 0 12 12" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="4 2 8 6 4 10"/></svg>
        </span>
        <span style={{ flex: 1 }}>{label}</span>
        {count != null && (
          <span style={{
            fontSize: 10, fontWeight: 600, fontVariantNumeric: 'tabular-nums',
            color: 'rgba(255,255,255,0.45)',
            textTransform: 'none', letterSpacing: 0,
          }}>{count}</span>
        )}
        {action && (
          <button onClick={(e) => e.stopPropagation()} style={{
            width: 22, height: 22, borderRadius: 6,
            background: 'transparent', border: 'none',
            color: 'rgba(255,255,255,0.55)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            cursor: 'pointer',
          }}>{action}</button>
        )}
      </div>
      {open && (
        <div style={{ paddingBottom: 4 }}>{children}</div>
      )}
    </div>
  );
};

// Brand logo strip — uses the real logo PNG. Falls back to a synth SVG
// only if the image fails to load.
const BrandStrip = ({ small = false, showWordmark = true }) => (
  <div style={{
    display: 'flex', alignItems: 'center', gap: 10,
    padding: small ? '14px 18px 10px 18px' : '18px 18px 12px 20px',
  }}>
    <img
      src="assets/TaskMaestro_Logo.jpg"
      alt="TaskMaestro"
      style={{
        width: small ? 28 : 32, height: small ? 28 : 32,
        borderRadius: 8,
        objectFit: 'cover',
        boxShadow: '0 0 0 1px rgba(0,0,0,0.25), 0 4px 10px rgba(0,0,0,0.25)',
        flexShrink: 0,
      }}
    />
    {showWordmark && <div style={{ fontWeight: 700, fontSize: 15.5, letterSpacing: 0.2, color: '#fff' }}>TaskMaestro</div>}
  </div>
);

const SidebarItem = ({ icon, dot, label, sub, active, locked, count, soonText = 'soon' }) => (
  <div style={{
    display: 'flex', alignItems: 'center', gap: 11,
    margin: '1px 10px',
    padding: '8px 11px',
    borderRadius: 10,
    background: active ? 'rgba(0,0,0,0.28)' : 'transparent',
    color: locked ? 'rgba(255,255,255,0.50)' : 'rgba(255,255,255,0.92)',
    cursor: locked ? 'default' : 'pointer',
    fontSize: 13.5,
    fontWeight: active ? 600 : 500,
  }}>
    {icon ? (
      <span style={{ width: 20, display: 'inline-flex', justifyContent: 'center', color: 'currentColor' }}>{icon}</span>
    ) : dot ? (
      <span style={{ width: 20, display: 'inline-flex', justifyContent: 'center' }}>
        <span style={{ width: 10, height: 10, borderRadius: '50%', background: dot, opacity: locked ? 0.45 : 1 }}/>
      </span>
    ) : <span style={{ width: 20 }}/>}
    <span style={{ flex: 1, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{label}</span>
    {sub && <span style={{ fontSize: 11, color: 'rgba(255,255,255,0.55)' }}>{sub}</span>}
    {count != null && (
      <span style={{
        fontSize: 11, fontWeight: 600,
        color: 'rgba(255,255,255,0.55)',
        fontVariantNumeric: 'tabular-nums',
      }}>{count}</span>
    )}
    {locked && (
      <span style={{
        fontSize: 9.5, fontWeight: 700, letterSpacing: 0.5,
        textTransform: 'uppercase',
        color: 'rgba(255,255,255,0.4)',
        padding: '2px 6px', borderRadius: 4,
        border: '1px dashed rgba(255,255,255,0.18)',
      }}>{soonText}</span>
    )}
  </div>
);

// ============================================================
// Sidebar — Direction 1 (Navigation-forward)
//
// Layout:
//   [BrandStrip]               (fixed)
//   [+ Add task] [Search]      (fixed)
//   [scrollable section list]  (flex:1, overflow-y:auto)
//     [Destinations]   collapsible
//     [Sprints]        collapsible
//     [Areas]          collapsible (scrolls inside if very long)
//     [Coming Soon]    collapsible
//   [Profile footer]           (fixed)
// ============================================================
const Sidebar = ({ activeDest = 'tasks', activeAreaName, areas, narrow = false, defaultOpen }) => {
  const o = Object.assign({
    destinations: true, areas: true, comingSoon: true,
  }, defaultOpen || {});
  return (
    <div style={{
      width: narrow ? 232 : 264,
      background: 'var(--brand-blue)', color: '#fff',
      display: 'flex', flexDirection: 'column',
      flexShrink: 0,
      fontSize: 14,
      borderRight: '1px solid rgba(0,0,0,0.22)',
      overflow: 'hidden',
    }}>
      <BrandStrip/>

      {/* Add task — the FAB lives here on wide screens */}
      <button style={{
        display: 'flex', alignItems: 'center', gap: 10,
        margin: '4px 14px 8px',
        padding: '11px 14px',
        borderRadius: 14,
        background: 'var(--brand-magenta-muted)',
        border: 'none', color: '#fff',
        fontSize: 13.5, fontWeight: 600, cursor: 'pointer',
        boxShadow: '0 4px 14px rgba(216,58,255,0.30)',
      }}>
        <Icon name="plus" size={17}/>
        Add task
      </button>

      {/* Search */}
      <div style={{
        display: 'flex', alignItems: 'center', gap: 9,
        margin: '4px 14px 6px',
        padding: '8px 12px',
        borderRadius: 10,
        background: 'rgba(0,0,0,0.20)',
        color: 'rgba(255,255,255,0.65)',
        fontSize: 12.5,
        border: '1px solid rgba(255,255,255,0.06)',
      }}>
        <Icon name="search" size={14}/>
        <span style={{ flex: 1 }}>Search tasks...</span>
        <span style={{ fontSize: 10.5, color: 'rgba(255,255,255,0.4)', padding: '1px 5px', border: '1px solid rgba(255,255,255,0.18)', borderRadius: 4, fontFamily: 'ui-monospace, monospace' }}>/</span>
      </div>

      {/* SCROLLABLE section list. Sprints + saved views are intentionally
          NOT here: Plan already shows the active sprint, and saved-view
          shortcuts compete with the View Options filter for the same job.
          Areas stay because they earn the spot — they have color identity
          and users scope to them constantly. Clicking an area is
          equivalent to setting the Areas filter in View Options. */}
      <div style={{ flex: 1, minHeight: 0, overflowY: 'auto', paddingBottom: 6 }}>
        <CollapsibleSection label="Destinations" defaultOpen={o.destinations}>
          <SidebarItem icon={<Icon name="plan"/>} label="Plan" active={activeDest === 'plan'}/>
          <SidebarItem icon={<Icon name="tasks"/>} label="Tasks" count="42" active={activeDest === 'tasks'}/>
          <SidebarItem icon={<Icon name="family"/>} label="Family" count="7" active={activeDest === 'family'}/>
          <SidebarItem icon={<Icon name="stats"/>} label="Stats" active={activeDest === 'stats'}/>
        </CollapsibleSection>

        <CollapsibleSection label="Areas" count={areas.length} defaultOpen={o.areas} action={<Icon name="plus" size={13}/>}>
          {areas.map(a => (
            <SidebarItem key={a.name} dot={a.color} label={a.name} count={a.count} active={activeAreaName === a.name}/>
          ))}
        </CollapsibleSection>

        <CollapsibleSection label="Coming Soon" defaultOpen={o.comingSoon}>
          <SidebarItem icon={<Icon name="goals"/>} label="Yearly Goals" locked/>
          <SidebarItem icon={<Icon name="month"/>} label="Monthly Plan" locked/>
          <SidebarItem icon={<Icon name="project"/>} label="Projects" locked/>
        </CollapsibleSection>
      </div>

      {/* footer profile (always pinned) */}
      <div style={{
        display: 'flex', alignItems: 'center', gap: 10,
        padding: '12px 16px 18px',
        borderTop: '1px solid rgba(0,0,0,0.20)',
        flexShrink: 0,
      }}>
        <div style={{
          width: 30, height: 30, borderRadius: '50%',
          background: 'linear-gradient(135deg, #D83AFF 0%, #C45EE0 100%)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          color: '#fff', fontSize: 12, fontWeight: 700,
          flexShrink: 0,
        }}>SP</div>
        <div style={{ flex: 1, fontSize: 13, minWidth: 0 }}>
          <div style={{ fontWeight: 600, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>Sam Patel</div>
          <div style={{ fontSize: 10.5, color: 'rgba(255,255,255,0.55)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>Personal · Family</div>
        </div>
      </div>
    </div>
  );
};

// ============================================================
// NavRail — Direction 2 (Master-detail)
// ============================================================
const NavRail = ({ activeDest = 'tasks', areasOpen, narrow = false }) => {
  const items = [
    { key: 'plan',   icon: 'plan',   label: 'Plan' },
    { key: 'tasks',  icon: 'tasks',  label: 'Tasks' },
    { key: 'family', icon: 'family', label: 'Family' },
    { key: 'stats',  icon: 'stats',  label: 'Stats' },
    { key: 'areas',  icon: 'areas',  label: 'Areas' },
  ];
  const w = narrow ? 76 : 88;
  return (
    <div style={{
      width: w, background: 'var(--brand-blue)', color: '#fff',
      display: 'flex', flexDirection: 'column',
      flexShrink: 0,
      borderRight: '1px solid rgba(0,0,0,0.22)',
    }}>
      {/* logo */}
      <div style={{
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        padding: '16px 0 14px',
      }}>
        <img
          src="assets/TaskMaestro_Logo.jpg"
          alt="TaskMaestro"
          style={{
            width: 38, height: 38, borderRadius: 9,
            objectFit: 'cover',
            boxShadow: '0 0 0 1px rgba(0,0,0,0.25), 0 4px 10px rgba(0,0,0,0.30)',
          }}
        />
      </div>
      {/* the FAB */}
      <button style={{
        margin: '0 16px 18px',
        height: 56, borderRadius: 16,
        background: 'var(--brand-magenta-muted)',
        border: 'none', color: '#fff',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        cursor: 'pointer',
        boxShadow: '0 4px 14px rgba(216,58,255,0.30)',
      }}>
        <Icon name="plus" size={24}/>
      </button>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
        {items.map(it => {
          const active = activeDest === it.key || (it.key === 'areas' && areasOpen);
          return (
            <div key={it.key} style={{
              display: 'flex', flexDirection: 'column', alignItems: 'center',
              padding: '5px 0', cursor: 'pointer',
            }}>
              <div style={{
                width: 56, height: 32, borderRadius: 16,
                background: active ? 'rgba(0,0,0,0.28)' : 'transparent',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                color: '#fff',
              }}>
                <Icon name={it.icon} size={20}/>
              </div>
              <div style={{
                marginTop: 4, fontSize: 10.5,
                fontWeight: active ? 600 : 500,
                color: active ? '#fff' : 'rgba(255,255,255,0.85)',
              }}>{it.label}</div>
            </div>
          );
        })}
      </div>

      <div style={{ flex: 1, minHeight: 14 }}/>
      <div style={{
        display: 'flex', justifyContent: 'center',
        padding: '12px 0 16px',
        borderTop: '1px solid rgba(0,0,0,0.20)',
      }}>
        <div style={{
          width: 32, height: 32, borderRadius: '50%',
          background: 'linear-gradient(135deg, #D83AFF 0%, #C45EE0 100%)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          color: '#fff', fontSize: 12, fontWeight: 700,
        }}>SP</div>
      </div>
    </div>
  );
};

// ============================================================
// RailAreasDrawer — secondary drawer when "Areas" tab is selected
// in Direction 2. This is where Sprints and the upcoming Goals /
// Monthly / Projects placeholders live in the rail layout.
// ============================================================
const RailAreasDrawer = ({ areas, activeAreaName, width = 244 }) => (
  <div style={{
    width, background: 'var(--bg-deep)', color: '#fff',
    display: 'flex', flexDirection: 'column',
    borderRight: '1px solid rgba(0,0,0,0.18)',
    flexShrink: 0,
  }}>
    <div style={{
      padding: '20px 18px 6px',
      fontSize: 16, fontWeight: 600,
    }}>Areas</div>
    <div style={{
      padding: '0 18px 10px',
      fontSize: 12, color: 'rgba(255,255,255,0.55)', lineHeight: 1.5,
    }}>Scope the Tasks list to a single area.</div>

    <SidebarLabel action={<Icon name="plus" size={13}/>}>All areas</SidebarLabel>
    <div style={{ flex: 1, overflowY: 'auto' }}>
      {areas.map(a => (
        <SidebarItem key={a.name} dot={a.color} label={a.name} count={a.count} active={activeAreaName === a.name}/>
      ))}
    </div>

    <SidebarLabel>Coming Soon</SidebarLabel>
    <SidebarItem icon={<Icon name="goals"/>} label="Yearly Goals" locked/>
    <SidebarItem icon={<Icon name="month"/>} label="Monthly Plan" locked/>
    <SidebarItem icon={<Icon name="project"/>} label="Projects" locked/>
    <div style={{ height: 16 }}/>
  </div>
);

// ============================================================
// SprintBanner — top of the list center column
// ============================================================
const SprintBanner = ({ sprint }) => (
  <div style={{
    margin: '14px 18px 8px',
    padding: '14px 16px',
    borderRadius: 12,
    background: 'linear-gradient(95deg, rgba(216,58,255,0.16) 0%, rgba(216,58,255,0.04) 100%)',
    border: '1px solid rgba(216,58,255,0.30)',
    display: 'flex', alignItems: 'center', gap: 16,
  }}>
    <div style={{
      width: 40, height: 40, borderRadius: 10,
      background: 'rgba(216,58,255,0.20)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      color: '#F4C8F9',
      flexShrink: 0,
    }}>
      <Icon name="sprint" size={20}/>
    </div>
    <div style={{ flex: 1, minWidth: 0 }}>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 10 }}>
        <div style={{ fontSize: 10.5, fontWeight: 700, color: 'rgba(255,210,245,0.95)', textTransform: 'uppercase', letterSpacing: 0.7 }}>Active sprint</div>
        <div style={{ fontSize: 11, color: 'rgba(255,255,255,0.55)' }}>{sprint.daysLeft} days left · ends {sprint.endsDate}</div>
      </div>
      <div style={{ fontSize: 15, fontWeight: 600, marginTop: 2, color: '#fff' }}>{sprint.name}</div>
      <div style={{
        marginTop: 8, display: 'flex', alignItems: 'center', gap: 10,
      }}>
        <div style={{ flex: 1, height: 4, borderRadius: 2, background: 'rgba(255,255,255,0.10)', overflow: 'hidden' }}>
          <div style={{ width: `${(sprint.completed/sprint.total)*100}%`, height: '100%', background: 'var(--brand-magenta-muted)' }}/>
        </div>
        <div style={{ fontSize: 11.5, fontWeight: 600, color: 'rgba(255,255,255,0.78)', fontVariantNumeric: 'tabular-nums' }}>{sprint.completed}/{sprint.total}</div>
      </div>
    </div>
    <button style={{
      background: 'transparent', border: '1px solid rgba(255,255,255,0.14)',
      color: 'rgba(255,255,255,0.78)',
      padding: '7px 12px', borderRadius: 8,
      fontSize: 12, fontWeight: 600, cursor: 'pointer',
    }}>View sprint →</button>
  </div>
);

// ============================================================
// ListAppBar — center column header
// ============================================================
const appbarIconBtn = {
  width: 36, height: 36, borderRadius: 10,
  background: 'transparent', border: 'none', color: 'rgba(255,255,255,0.92)',
  display: 'flex', alignItems: 'center', justifyContent: 'center',
  cursor: 'pointer',
};

// No magnifying-glass icon — global search lives in the sidebar. The app
// bar only carries the view-options toggle and a more-menu.
const ListAppBar = ({ title = 'Tasks', subtitle, showViewToggle, viewOptionsOpen, breadcrumbs = [] }) => (
  <div style={{
    background: 'var(--brand-blue)',
    padding: '14px 20px',
    display: 'flex', alignItems: 'center', gap: 14,
    color: '#fff',
    borderBottom: '1px solid rgba(0,0,0,0.18)',
    flexShrink: 0,
  }}>
    <div style={{ flex: 1, minWidth: 0 }}>
      {breadcrumbs.length > 0 && (
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 11.5, color: 'rgba(255,255,255,0.62)', marginBottom: 3 }}>
          {breadcrumbs.map((b, i) => (
            <React.Fragment key={i}>
              {i > 0 && <Icon name="chev-r" size={11}/>}
              <span>{b}</span>
            </React.Fragment>
          ))}
        </div>
      )}
      <div style={{ fontSize: 19, fontWeight: 500, letterSpacing: 0.1 }}>{title}</div>
      {subtitle && <div style={{ fontSize: 12, color: 'rgba(255,255,255,0.62)', marginTop: 2 }}>{subtitle}</div>}
    </div>
    <div style={{ display: 'flex', gap: 4 }}>
      {showViewToggle && (
        <button title="View options" style={{
          ...appbarIconBtn,
          background: viewOptionsOpen ? 'rgba(0,0,0,0.28)' : 'transparent',
        }}>
          <Icon name="sliders" size={18}/>
        </button>
      )}
      <button style={appbarIconBtn} title="More">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><circle cx="5.5" cy="12" r="1.7"/><circle cx="12" cy="12" r="1.7"/><circle cx="18.5" cy="12" r="1.7"/></svg>
      </button>
    </div>
  </div>
);

// ============================================================
// RightPaneEmpty — when nothing is selected
// ============================================================
const RightPaneEmpty = () => (
  <div style={{
    flex: 1, display: 'flex', flexDirection: 'column',
    alignItems: 'center', justifyContent: 'center',
    padding: 30, color: 'rgba(255,255,255,0.6)',
    textAlign: 'center',
  }}>
    <div style={{
      width: 92, height: 92, borderRadius: 22,
      background: 'rgba(255,255,255,0.04)',
      border: '1px solid rgba(255,255,255,0.10)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      marginBottom: 18,
      color: 'rgba(255,255,255,0.45)',
      position: 'relative',
    }}>
      {/* tiny task-card glyph */}
      <svg width="46" height="46" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
        <rect x="3.5" y="5.5" width="17" height="13" rx="2"/>
        <path d="M3.5 9.5h17"/>
        <circle cx="7" cy="13.5" r="1.3"/>
        <path d="M9.5 13.5h7"/>
      </svg>
      <div style={{
        position: 'absolute', bottom: -6, right: -6,
        width: 22, height: 22, borderRadius: 6,
        background: '#D83AFF',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        color: '#fff',
      }}>
        <svg width="13" height="13" viewBox="0 0 16 16" fill="none" stroke="#fff" strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round">
          <polyline points="3,8.5 6.5,12 13,4"/>
        </svg>
      </div>
    </div>
    <div style={{ fontSize: 15, color: 'rgba(255,255,255,0.92)', fontWeight: 600 }}>Select a task</div>
    <div style={{ fontSize: 12.5, marginTop: 6, maxWidth: 260, lineHeight: 1.5, color: 'rgba(255,255,255,0.55)' }}>
      Click any row to edit it here — the pane stays open while you move through the list.
    </div>
    <div style={{
      marginTop: 24, display: 'flex', alignItems: 'center', gap: 6,
      fontSize: 11, color: 'rgba(255,255,255,0.45)',
    }}>
      <Kbd>N</Kbd> new task
      <span style={{ opacity: 0.5 }}>·</span>
      <Kbd>/</Kbd> search
      <span style={{ opacity: 0.5 }}>·</span>
      <Kbd>J</Kbd><Kbd>K</Kbd> next/prev
    </div>
  </div>
);

const Kbd = ({ children }) => (
  <span style={{
    padding: '1.5px 6px', borderRadius: 4,
    background: 'rgba(255,255,255,0.05)',
    border: '1px solid rgba(255,255,255,0.14)',
    fontFamily: 'ui-monospace, monospace', fontSize: 10.5,
    color: 'rgba(255,255,255,0.75)',
    fontWeight: 600,
  }}>{children}</span>
);

window.TMChrome = {
  Sidebar, NavRail, RailAreasDrawer, SprintBanner, ListAppBar,
  RightPaneEmpty, SidebarItem, SidebarLabel, CollapsibleSection,
  BrandStrip, Icon, Kbd,
};
