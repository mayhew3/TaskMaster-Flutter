// wide-view-options.jsx — View options panel for the wide layout.
// Pixel-faithful port of the phone bottom-sheet reference: Group + Sort
// dropdowns, "FILTER BY" sub-header, then dropdowns + min/max chip rows for
// Due status, Estimated time, Points, Priority, Areas, Contexts, Recurrence,
// Age — ending in a Cancel / Apply Changes action bar.

const { Icon } = window.TMChrome;

// ---------- shared atoms ----------

// "Group" / "Sort" / "Areas" etc. — small uppercase-style label sitting just
// above a control.
const VOLabel = ({ children, dense = false }) => (
  <div style={{
    fontSize: 12, fontWeight: 500,
    color: 'rgba(255,255,255,0.85)',
    marginBottom: dense ? 5 : 7,
    letterSpacing: 0.1,
  }}>{children}</div>
);

// FILTER BY divider (the uppercase letter-spaced subhead from the reference).
const VOSubhead = ({ children }) => (
  <div style={{
    fontSize: 11, fontWeight: 700, letterSpacing: 1.4,
    textTransform: 'uppercase',
    color: 'rgba(255,255,255,0.55)',
    margin: '14px 0 8px',
  }}>{children}</div>
);

// Filled dropdown — used for Group / Sort / Due status / Areas / Contexts /
// Recurrence / Age. Matches the reference: brighter brand-blue fill, thin
// white border, white text, chev-down on the right.
const VODropdown = ({ value, placeholder, fullWidth = false }) => (
  <button style={{
    width: fullWidth ? '100%' : 'auto',
    minWidth: 0,
    display: 'flex', alignItems: 'center', gap: 8,
    padding: '10px 12px 10px 14px',
    background: 'rgba(143,184,255,0.22)',
    border: '1px solid rgba(255,255,255,0.20)',
    borderRadius: 9,
    color: value ? '#fff' : 'rgba(255,255,255,0.55)',
    fontSize: 13.5, fontWeight: 500,
    cursor: 'pointer',
    fontFamily: 'inherit',
    textAlign: 'left',
  }}>
    <span style={{ flex: 1, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{value || placeholder}</span>
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.85)" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <polyline points="6 9 12 15 18 9"/>
    </svg>
  </button>
);

// Sort-direction toggle (the ↑ button in the reference).
const VOSortDirBtn = ({ dir = 'asc' }) => (
  <button title={dir === 'asc' ? 'Ascending' : 'Descending'} style={{
    width: 38, height: 38, padding: 0,
    background: 'rgba(143,184,255,0.22)',
    border: '1px solid rgba(255,255,255,0.20)',
    borderRadius: 9,
    color: '#fff',
    cursor: 'pointer',
    display: 'flex', alignItems: 'center', justifyContent: 'center',
    flexShrink: 0,
  }}>
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      {dir === 'asc'
        ? <path d="M12 19V5M6 11l6-6 6 6"/>
        : <path d="M12 5v14M18 13l-6 6-6-6"/>}
    </svg>
  </button>
);

// Range chip used by Estimated time / Points / Priority. Three visual states:
// idle (translucent dark), selected (filled brighter blue), in-range (a
// halfway state, lighter translucent fill).
const VORangeChip = ({ children, selected, inRange, onClick }) => {
  const bg = selected
    ? 'rgba(143,184,255,0.85)'
    : inRange
      ? 'rgba(143,184,255,0.18)'
      : 'rgba(0,0,0,0.18)';
  const border = selected
    ? '1px solid rgba(255,255,255,0.6)'
    : '1px solid rgba(255,255,255,0.20)';
  const color = selected ? 'rgba(20,30,60,0.95)' : '#fff';
  return (
    <button onClick={onClick} style={{
      flex: 1, minWidth: 0,
      padding: '8px 4px',
      background: bg, border, borderRadius: 9,
      color, fontSize: 12.5, fontWeight: selected ? 700 : 500,
      cursor: 'pointer', fontFamily: 'inherit',
      fontVariantNumeric: 'tabular-nums',
      transition: 'background 120ms',
    }}>{children}</button>
  );
};

// One row of chips with a left-side "Min" / "Max" label.
const VOChipRow = ({ label, options, selectedIndex, otherIndex }) => (
  <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
    <div style={{
      width: 32, fontSize: 12, fontWeight: 500,
      color: 'rgba(255,255,255,0.78)', flexShrink: 0,
    }}>{label}</div>
    <div style={{ flex: 1, display: 'flex', gap: 4 }}>
      {options.map((opt, i) => (
        <VORangeChip
          key={i}
          selected={i === selectedIndex}
          inRange={otherIndex != null && ((i > selectedIndex && i < otherIndex) || (i > otherIndex && i < selectedIndex))}
        >{opt}</VORangeChip>
      ))}
    </div>
  </div>
);

// "Estimated time" / "Points" / "Priority" — heading + min row + max row.
const VOMinMaxBlock = ({ title, options, minIdx, maxIdx }) => (
  <div style={{ marginBottom: 16 }}>
    <VOLabel>{title}</VOLabel>
    <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
      <VOChipRow label="Min" options={options} selectedIndex={minIdx} otherIndex={maxIdx}/>
      <VOChipRow label="Max" options={options} selectedIndex={maxIdx} otherIndex={minIdx}/>
    </div>
  </div>
);

// ============================================================
// ViewOptionsPanel — full content for the wide-screen side panel.
// All state values are presentational (this is a mock); the
// layout is a 1:1 port of the phone reference.
// ============================================================
const ViewOptionsPanel = ({ onClose, embedded = false, dense = false }) => {
  const padX = dense ? 16 : 20;

  return (
    <div style={{
      display: 'flex', flexDirection: 'column',
      height: '100%',
      background: embedded ? 'transparent' : 'var(--card)',
      color: '#fff',
      overflow: 'hidden',
    }}>
      {/* header */}
      <div style={{
        display: 'flex', alignItems: 'center', gap: 12,
        padding: `16px ${padX}px 12px`,
        flexShrink: 0,
      }}>
        <div style={{ flex: 1, fontSize: 17, fontWeight: 600, letterSpacing: 0.1 }}>View options</div>
        <button style={{
          display: 'inline-flex', alignItems: 'center', gap: 6,
          background: 'transparent', border: 'none',
          color: 'rgba(255,255,255,0.85)',
          fontSize: 12.5, fontWeight: 500,
          cursor: 'pointer', padding: '4px 6px',
          fontFamily: 'inherit',
        }}>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <polyline points="23 4 23 10 17 10"/>
            <path d="M20.49 15A9 9 0 1 1 18.36 5.64L23 10"/>
          </svg>
          Reset to defaults
        </button>
        {onClose && (
          <button onClick={onClose} style={{
            width: 30, height: 30, borderRadius: 8,
            background: 'rgba(0,0,0,0.18)', border: '1px solid rgba(255,255,255,0.12)',
            color: 'rgba(255,255,255,0.78)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            cursor: 'pointer',
          }}>
            <Icon name="x" size={14}/>
          </button>
        )}
      </div>

      {/* body */}
      <div style={{ flex: 1, minHeight: 0, overflowY: 'auto', padding: `0 ${padX}px 12px` }}>
        {/* Group + Sort + direction */}
        <div style={{ display: 'flex', gap: 10, alignItems: 'flex-end' }}>
          <div style={{ flex: 1, minWidth: 0 }}>
            <VOLabel>Group</VOLabel>
            <VODropdown value="Due Status" fullWidth/>
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <VOLabel>Sort</VOLabel>
            <VODropdown value="Urgency" fullWidth/>
          </div>
          <VOSortDirBtn dir="asc"/>
        </div>

        {/* FILTER BY divider */}
        <VOSubhead>Filter by</VOSubhead>

        {/* Due status */}
        <div style={{ marginBottom: 16 }}>
          <VOLabel>Due status</VOLabel>
          <VODropdown value="All" fullWidth/>
        </div>

        {/* Estimated time */}
        <VOMinMaxBlock
          title="Estimated time"
          options={['5m','15m','30m','1h','2h','4h','8h','1d']}
          minIdx={1}
          maxIdx={5}
        />

        {/* Points */}
        <VOMinMaxBlock
          title="Points"
          options={['1','2','3','5','8','Other']}
          minIdx={0}
          maxIdx={3}
        />

        {/* Priority */}
        <VOMinMaxBlock
          title="Priority"
          options={['1','2','3','4','5']}
          minIdx={1}
          maxIdx={3}
        />

        {/* Areas + Contexts */}
        <div style={{ display: 'flex', gap: 10, marginBottom: 14 }}>
          <div style={{ flex: 1, minWidth: 0 }}>
            <VOLabel>Areas</VOLabel>
            <VODropdown value="All" fullWidth/>
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <VOLabel>Contexts</VOLabel>
            <VODropdown value="All" fullWidth/>
          </div>
        </div>

        {/* Recurrence + Age */}
        <div style={{ display: 'flex', gap: 10, marginBottom: 4 }}>
          <div style={{ flex: 1, minWidth: 0 }}>
            <VOLabel>Recurrence</VOLabel>
            <VODropdown value="Any" fullWidth/>
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <VOLabel>Age</VOLabel>
            <VODropdown value="Any" fullWidth/>
          </div>
        </div>
      </div>

      {/* action bar — pinned. Cancel is outlined, Apply is the primary. */}
      <div style={{
        padding: `12px ${padX}px 16px`,
        display: 'flex', gap: 10,
        flexShrink: 0,
        background: 'linear-gradient(to top, var(--card) 70%, transparent)',
      }}>
        <button style={{
          flex: 1,
          padding: '12px 16px', borderRadius: 999,
          background: 'transparent',
          border: '1px solid rgba(255,255,255,0.55)',
          color: '#fff',
          fontSize: 13, fontWeight: 600,
          cursor: 'pointer', fontFamily: 'inherit',
        }}>Cancel</button>
        <button style={{
          flex: 1,
          padding: '12px 16px', borderRadius: 999,
          background: 'rgba(143,184,255,0.40)',
          border: '1px solid rgba(143,184,255,0.55)',
          color: 'rgba(255,255,255,0.85)',
          fontSize: 13, fontWeight: 600,
          cursor: 'pointer', fontFamily: 'inherit',
        }}>Apply Changes</button>
      </div>
    </div>
  );
};

// ============================================================
// ViewOptionsHandle — vertical strip shown when the panel is
// collapsed. Direction 2 uses it between list and editor.
// ============================================================
const ViewOptionsHandle = ({ summary }) => (
  <div style={{
    width: 44, background: 'var(--bg-deep)',
    display: 'flex', flexDirection: 'column', alignItems: 'center',
    padding: '12px 0', flexShrink: 0,
    borderLeft: '1px solid rgba(0,0,0,0.18)',
    borderRight: '1px solid rgba(0,0,0,0.18)',
    color: 'rgba(255,255,255,0.7)', gap: 14,
  }}>
    <div style={{
      width: 32, height: 32, borderRadius: 10,
      background: 'rgba(255,255,255,0.06)',
      border: '1px solid rgba(255,255,255,0.10)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      color: '#fff', cursor: 'pointer',
    }}>
      <Icon name="sliders" size={16}/>
    </div>
    <div style={{
      writingMode: 'vertical-rl', transform: 'rotate(180deg)',
      fontSize: 10.5, fontWeight: 700, letterSpacing: 1.1,
      textTransform: 'uppercase', color: 'rgba(255,255,255,0.55)',
    }}>View options</div>
    <div style={{ flex: 1 }}/>
    {summary && (
      <div style={{
        writingMode: 'vertical-rl', transform: 'rotate(180deg)',
        fontSize: 10, color: 'rgba(255,255,255,0.4)',
        textAlign: 'center', lineHeight: 1.4,
      }}>{summary}</div>
    )}
  </div>
);

// ============================================================
// ViewOptionsSummaryBar — slim chip row under the app bar that
// shows the current grouping / sort / filter at a glance. Stays
// visible whether the panel is open or closed.
// ============================================================
const VOChip = ({ label, value, active }) => (
  <span style={{
    display: 'inline-flex', alignItems: 'center', gap: 5,
    padding: '4px 9px 4px 8px',
    borderRadius: 999,
    background: active ? 'rgba(143,184,255,0.20)' : 'rgba(255,255,255,0.05)',
    border: active ? '1px solid rgba(143,184,255,0.40)' : '1px solid rgba(255,255,255,0.10)',
    fontSize: 11.5, color: 'rgba(255,255,255,0.85)', cursor: 'pointer',
  }}>
    <span style={{ fontSize: 10, fontWeight: 700, textTransform: 'uppercase', letterSpacing: 0.5, color: 'rgba(255,255,255,0.5)' }}>{label}</span>
    <span style={{ fontWeight: 600 }}>{value}</span>
  </span>
);

const ViewOptionsSummaryBar = ({ group, sort, sortDir, count }) => (
  <div style={{
    display: 'flex', alignItems: 'center', gap: 7,
    padding: '10px 20px',
    background: 'rgba(0,0,0,0.18)',
    borderBottom: '1px solid rgba(255,255,255,0.04)',
    fontSize: 12,
  }}>
    <VOChip label="Group" value={group}/>
    <VOChip label="Sort" value={`${sort} ${sortDir === 'asc' ? '↑' : '↓'}`}/>
    <div style={{ flex: 1 }}/>
    <span style={{ fontSize: 11.5, color: 'rgba(255,255,255,0.55)', fontVariantNumeric: 'tabular-nums' }}>
      {count} tasks
    </span>
  </div>
);

window.TMViewOptions = {
  ViewOptionsPanel, ViewOptionsHandle, ViewOptionsSummaryBar, VOChip,
};
