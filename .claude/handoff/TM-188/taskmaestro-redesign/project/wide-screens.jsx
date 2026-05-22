// wide-screens.jsx — composition primitives for the wide-screen TaskMaestro layout.
// Provides TaskListPane (V9 cards + section headers + selection state),
// FrameLabel for in-canvas annotations, and ShellWrap that paints the
// outer var(--bg-deep) shell + rounded corners.

const { CardV9 } = window.TMCards;
const { ListAppBar, SprintBanner } = window.TMChrome;
const { ViewOptionsSummaryBar } = window.TMViewOptions;

// ============================================================
// Section header — matches the phone's uppercase letter-spaced label
// ============================================================
const ListSectionHeader = ({ label, hint }) => (
  <div style={{
    padding: '16px 24px 6px',
    display: 'flex', alignItems: 'baseline', gap: 10,
  }}>
    <span style={{
      fontSize: 11, fontWeight: 700, letterSpacing: 1.3,
      textTransform: 'uppercase', color: 'rgba(255,255,255,0.55)',
    }}>{label}</span>
    {hint && (
      <span style={{ fontSize: 11, color: 'rgba(255,255,255,0.40)', fontWeight: 500 }}>{hint}</span>
    )}
    <span style={{ flex: 1, height: 1, background: 'rgba(255,255,255,0.06)', marginLeft: 4 }}/>
  </div>
);

// ============================================================
// Selectable wrapper for V9 cards. CardV9 already has its own
// margin: 4px 8px — we wrap it in a position:relative outer and
// paint the selection ring as an absolutely positioned outline so
// the card geometry is untouched.
// ============================================================
const SelectableCard = ({ task, selected }) => (
  <div style={{ position: 'relative' }}>
    <CardV9 task={task}/>
    {selected && (
      <div style={{
        position: 'absolute',
        inset: '4px 8px',
        borderRadius: 7,
        boxShadow: '0 0 0 2px #D83AFF, 0 4px 22px rgba(216,58,255,0.30)',
        pointerEvents: 'none',
      }}/>
    )}
  </div>
);

// ============================================================
// TaskListPane — center column. Section headers + V9 rows. The
// list is grouped into Urgent / Target / This week / No date and
// optionally constrained to a calm max-width column.
// ============================================================
const TaskListPane = ({
  tasks, selectedId,
  showSprintBanner, sprint,
  showViewToggle, viewOptionsOpen,
  showSummaryBar = true,
  viewOptions,
  maxWidth = null,                    // e.g. 720 for Direction 1
  title = 'Tasks',
  subtitle,
  breadcrumbs = [],
  flush = false,                       // when true, no inner padding
}) => {
  const urgent = tasks.filter(t => t.dateKind === 'urgent' || t.dateKind === 'due');
  const target = tasks.filter(t => t.dateKind === 'target');
  const noDate = tasks.filter(t => !t.dateKind && !t.completed && !t.skipped);
  const done   = tasks.filter(t => t.completed || t.skipped);

  return (
    <div style={{
      flex: 1, minWidth: 0,
      background: 'var(--bg)',
      display: 'flex', flexDirection: 'column',
      overflow: 'hidden',
    }}>
      <ListAppBar
        title={title}
        subtitle={subtitle}
        breadcrumbs={breadcrumbs}
        showViewToggle={showViewToggle}
        viewOptionsOpen={viewOptionsOpen}
      />
      {showSummaryBar && viewOptions && (
        <ViewOptionsSummaryBar {...viewOptions} count={tasks.length}/>
      )}
      <div style={{ flex: 1, overflowY: 'auto', paddingBottom: 32 }}>
        <div style={{
          maxWidth: maxWidth || '100%',
          margin: maxWidth ? '0 auto' : 0,
          paddingTop: 2,
        }}>
          {showSprintBanner && sprint && <SprintBanner sprint={sprint}/>}

          {urgent.length > 0 && (
            <>
              <ListSectionHeader label="Urgent" hint={`${urgent.length} need attention`}/>
              {urgent.map(t => (
                <SelectableCard key={t.id} task={t} selected={selectedId === t.id}/>
              ))}
            </>
          )}
          {target.length > 0 && (
            <>
              <ListSectionHeader label="Target this week" hint={`${target.length} tasks`}/>
              {target.map(t => (
                <SelectableCard key={t.id} task={t} selected={selectedId === t.id}/>
              ))}
            </>
          )}
          {noDate.length > 0 && (
            <>
              <ListSectionHeader label="No date" hint={`${noDate.length} parked`}/>
              {noDate.map(t => (
                <SelectableCard key={t.id} task={t} selected={selectedId === t.id}/>
              ))}
            </>
          )}
          {done.length > 0 && (
            <>
              <ListSectionHeader label="Recently completed" hint={`${done.length} this week`}/>
              {done.map(t => (
                <SelectableCard key={t.id} task={t} selected={selectedId === t.id}/>
              ))}
            </>
          )}
        </div>
      </div>
    </div>
  );
};

// ============================================================
// FrameLabel — caption strip pinned to the top of each wide
// artboard, giving the in-canvas explanation of what state /
// breakpoint it represents.
// ============================================================
const FrameLabel = ({ kicker, title, sub }) => (
  <div style={{
    position: 'absolute', left: 0, right: 0, top: 0,
    padding: '14px 22px 14px',
    background: 'linear-gradient(180deg, rgba(0,0,0,0.55) 0%, rgba(0,0,0,0.0) 100%)',
    color: 'rgba(255,255,255,0.92)',
    display: 'flex', alignItems: 'center', gap: 14, pointerEvents: 'none',
    zIndex: 5,
  }}>
    <div style={{
      fontSize: 10.5, fontWeight: 700, letterSpacing: 1.4,
      textTransform: 'uppercase', color: 'rgba(255,255,255,0.65)',
      padding: '4px 9px', borderRadius: 5,
      background: 'rgba(0,0,0,0.45)', border: '1px solid rgba(255,255,255,0.12)',
    }}>{kicker}</div>
    <div style={{ flex: 1, minWidth: 0 }}>
      <div style={{ fontSize: 14, fontWeight: 600, letterSpacing: 0.1 }}>{title}</div>
      {sub && <div style={{ fontSize: 11.5, color: 'rgba(255,255,255,0.6)', marginTop: 1 }}>{sub}</div>}
    </div>
  </div>
);

// Wraps the screen inside the artboard, leaving room for FrameLabel up top.
const FrameInner = ({ children, topInset = 56 }) => (
  <div style={{
    position: 'absolute', inset: 0,
    paddingTop: topInset, boxSizing: 'border-box',
    display: 'flex',
    background: 'var(--bg-deep)',
  }}>
    {/* the "browser surface" — a rounded card containing the layout */}
    <div style={{
      flex: 1, margin: '6px 14px 14px',
      borderRadius: 10, overflow: 'hidden',
      display: 'flex',
      boxShadow: '0 8px 28px rgba(0,0,0,0.45), 0 0 0 1px rgba(255,255,255,0.04)',
    }}>{children}</div>
  </div>
);

window.TMScreens = {
  ListSectionHeader, SelectableCard, TaskListPane,
  FrameLabel, FrameInner,
};
