// Task card variations for TaskMaestro redesign.
// All cards consume the same `task` shape (see SAMPLE below).
// Brand: blue #2C74C5 (cards), pink/magenta #3FBF7A (logo accent — used sparingly).

const { useMemo } = React;

// --------- shared bits ---------

const AREA_COLORS = {
  Family:       '#E2A6F0',
  Maintenance:  '#F0B97A',
  Friends:      '#9DC8F0',
  Hobby:        '#A0E0B5',
  Shopping:     '#F0D77A',
  Organization: '#B5C9F0',
  Career:       '#F09A9A',
  Health:       '#7AE0C6',
  Entertainment:'#D8A0F0',
  Projects:     '#F09AC0',
};

const DATE_TONES = {
  due:    { fg: '#F4B0B0', bg: 'rgba(180, 60, 80, 0.28)',  border: 'rgba(244,176,176,0.4)' },
  urgent: { fg: '#F4C8A8', bg: 'rgba(180, 110, 50, 0.28)', border: 'rgba(244,200,168,0.4)' },
  target: { fg: '#EFE0A0', bg: 'rgba(140, 130, 50, 0.28)', border: 'rgba(239,224,160,0.4)' },
  start:  { fg: '#B3B5DD', bg: 'rgba(120, 130, 200, 0.22)', border: 'rgba(179,181,221,0.4)' },
};

// log-scale time bar: 5m → 0.05, 30m → 0.3, 1h → 0.4, 4h → 0.65, 1d → 0.85, 1w → 1.0
function timeFraction(minutes) {
  if (!minutes || minutes <= 0) return 0;
  // ln(1+m)/ln(1+10080)  -> 1 week as full
  const n = Math.log(1 + minutes) / Math.log(1 + 10080);
  return Math.max(0.04, Math.min(1, n));
}
function fmtTime(minutes) {
  if (!minutes) return '';
  if (minutes < 60) return `${minutes}m`;
  if (minutes < 60 * 24) {
    const h = minutes / 60;
    return h % 1 === 0 ? `${h}h` : `${h.toFixed(1)}h`;
  }
  const d = minutes / (60 * 24);
  return d % 1 === 0 ? `${d}d` : `${d.toFixed(1)}d`;
}

const ContextIcon = ({ name, size = 14, color = 'rgba(255,255,255,0.72)' }) => {
  const stroke = { fill: 'none', stroke: color, strokeWidth: 1.6, strokeLinecap: 'round', strokeLinejoin: 'round' };
  const filled = { fill: color, stroke: 'none' };
  switch (name) {
    case 'phone':
      return (<svg width={size} height={size} viewBox="0 0 16 16"><path d="M3 3.5C3 3 3.4 2.5 4 2.5h1.6c.5 0 1 .4 1 .9l.4 2.4c0 .4-.1.8-.5 1L5.5 7.6c.9 1.7 2.2 3 4 4l.7-1c.2-.4.6-.5 1-.5l2.4.4c.5 0 .9.5.9 1V13c0 .6-.5 1-1 1A11 11 0 0 1 3 3.5z" {...stroke}/></svg>);
    case 'email':
      return (<svg width={size} height={size} viewBox="0 0 16 16"><rect x="2" y="3.5" width="12" height="9" rx="1.2" {...stroke}/><path d="M2.5 4.5l5.5 4 5.5-4" {...stroke}/></svg>);
    case 'home':
      return (<svg width={size} height={size} viewBox="0 0 16 16"><path d="M2.5 7.5L8 3l5.5 4.5V13a.5.5 0 0 1-.5.5h-3v-4h-4v4h-3a.5.5 0 0 1-.5-.5V7.5z" {...stroke}/></svg>);
    case 'sun':
      return (<svg width={size} height={size} viewBox="0 0 16 16"><circle cx="8" cy="8" r="2.5" {...stroke}/><g {...stroke}><line x1="8" y1="2" x2="8" y2="3.6"/><line x1="8" y1="12.4" x2="8" y2="14"/><line x1="2" y1="8" x2="3.6" y2="8"/><line x1="12.4" y1="8" x2="14" y2="8"/><line x1="3.7" y1="3.7" x2="4.8" y2="4.8"/><line x1="11.2" y1="11.2" x2="12.3" y2="12.3"/><line x1="3.7" y1="12.3" x2="4.8" y2="11.2"/><line x1="11.2" y1="4.8" x2="12.3" y2="3.7"/></g></svg>);
    case 'computer':
      return (<svg width={size} height={size} viewBox="0 0 16 16"><rect x="2.5" y="3" width="11" height="7.5" rx="0.8" {...stroke}/><line x1="6" y1="13" x2="10" y2="13" {...stroke}/><line x1="8" y1="10.5" x2="8" y2="13" {...stroke}/></svg>);
    case 'errand':
      return (<svg width={size} height={size} viewBox="0 0 16 16"><path d="M3 5.5h10l-1 6.5H4l-1-6.5z" {...stroke}/><path d="M5.5 5.5V4a2.5 2.5 0 0 1 5 0v1.5" {...stroke}/></svg>);
    case 'car':
      return (<svg width={size} height={size} viewBox="0 0 16 16"><path d="M2.5 10.5V8l1.4-3a1 1 0 0 1 .9-.6h6.4a1 1 0 0 1 .9.6L13.5 8v2.5h-2v-1h-7v1h-2z" {...stroke}/><circle cx="5" cy="11.5" r="0.9" {...filled}/><circle cx="11" cy="11.5" r="0.9" {...filled}/></svg>);
    case 'people':
      return (<svg width={size} height={size} viewBox="0 0 16 16"><circle cx="6" cy="6" r="2" {...stroke}/><circle cx="11" cy="6.5" r="1.6" {...stroke}/><path d="M2.5 12.5c.4-2 1.8-3 3.5-3s3.1 1 3.5 3" {...stroke}/><path d="M9.5 12.5c.3-1.5 1.3-2.4 2.5-2.4s2.2.9 2.5 2.4" {...stroke}/></svg>);
  }
  return null;
};

const RecurringBadge = ({ size = 14, color = 'rgba(255,255,255,0.55)' }) => (
  <svg width={size} height={size} viewBox="0 0 16 16" aria-label="recurring">
    <path d="M3.5 8a4.5 4.5 0 0 1 7.6-3.3M12.5 8a4.5 4.5 0 0 1-7.6 3.3"
      fill="none" stroke={color} strokeWidth="1.6" strokeLinecap="round"/>
    <path d="M11.4 3.2v1.8h-1.8M4.6 12.8v-1.8h1.8" fill="none" stroke={color} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/>
  </svg>
);

const Checkbox = ({ checked = false, recurring = false, size = 28 }) => {
  if (checked) {
    return (
      <div style={{
        width: size, height: size, borderRadius: 6,
        background: '#D83AFF',
        border: '1.5px solid rgba(255,255,255,0.85)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        flexShrink: 0,
        boxShadow: '0 0 0 1px rgba(216,58,255,0.25)',
      }}>
        <svg width={size * 0.6} height={size * 0.6} viewBox="0 0 16 16" fill="none" stroke="#fff" strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round">
          <polyline points="3,8.5 6.5,12 13,4"/>
        </svg>
      </div>
    );
  }
  return (
    <div style={{
      width: size, height: size, borderRadius: 6,
      border: '1.5px solid rgba(255,255,255,0.7)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      background: 'transparent', flexShrink: 0,
    }}>
      {recurring && <RecurringBadge size={size * 0.55} color="rgba(255,255,255,0.55)" />}
    </div>
  );
};

const DatePill = ({ kind, label, time }) => {
  const t = DATE_TONES[kind];
  if (!t) return null;
  return (
    <div style={{
      display: 'inline-flex', alignItems: 'center', gap: 5,
      padding: '3px 9px',
      borderRadius: 999,
      background: t.bg,
      border: `1px solid ${t.border}`,
      color: t.fg,
      fontSize: 11, fontWeight: 600, letterSpacing: 0.2,
      whiteSpace: 'nowrap',
    }}>
      <span style={{ textTransform: 'uppercase', opacity: 0.85, fontSize: 10 }}>{label}</span>
      <span>{time}</span>
    </div>
  );
};

// pill specifically for completed/skipped state — uses brand magenta
const CompletedPill = ({ label = 'Completed', time = 'just now' }) => (
  <div style={{
    display: 'inline-flex', alignItems: 'center', gap: 5,
    padding: '3px 9px',
    borderRadius: 999,
    background: 'rgba(216,58,255,0.18)',
    border: '1px solid rgba(216,58,255,0.42)',
    color: '#F4C8F9',
    fontSize: 11, fontWeight: 600, letterSpacing: 0.2,
    whiteSpace: 'nowrap',
  }}>
    <span style={{ textTransform: 'uppercase', opacity: 0.9, fontSize: 10 }}>{label}</span>
    <span>{time}</span>
  </div>
);

const PointsCircle = ({ value, size = 26 }) => (
  <div style={{
    width: size, height: size, borderRadius: '50%',
    border: '1px solid rgba(255,255,255,0.32)',
    background: 'rgba(0,0,0,0.18)',
    display: 'flex', alignItems: 'center', justifyContent: 'center',
    color: 'rgba(255,255,255,0.92)',
    fontSize: 11, fontWeight: 700, letterSpacing: 0.3,
    flexShrink: 0,
  }}>{value}</div>
);

const TimeBar = ({ minutes, width = '100%', height = 3, color = 'rgba(179,181,221,0.85)' }) => {
  const f = timeFraction(minutes);
  return (
    <div style={{
      width, height, borderRadius: height,
      background: 'rgba(255,255,255,0.10)',
      overflow: 'hidden', position: 'relative',
    }}>
      <div style={{
        width: `${f * 100}%`, height: '100%',
        background: color, borderRadius: height,
      }}/>
    </div>
  );
};

const EnergyDots = ({ value, max = 3 }) => (
  <div style={{ display: 'inline-flex', gap: 2.5, alignItems: 'center' }}>
    {Array.from({length: max}).map((_, i) => (
      <span key={i} style={{
        width: 5, height: 5, borderRadius: '50%',
        background: i < value ? 'rgba(255,206,128,0.95)' : 'rgba(255,255,255,0.18)',
      }}/>
    ))}
  </div>
);

const ProjectDots = ({ step, total }) => (
  <div style={{ display: 'inline-flex', gap: 3, alignItems: 'center' }}>
    {Array.from({length: total}).map((_, i) => (
      <span key={i} style={{
        width: 5, height: 5, borderRadius: '50%',
        background: i < step ? '#3FBF7A' : 'rgba(255,255,255,0.22)',
      }}/>
    ))}
  </div>
);

const AreaStripe = ({ area }) => (
  <div style={{
    position: 'absolute', left: 0, top: 0, bottom: 0,
    width: 3, background: AREA_COLORS[area] || 'rgba(255,255,255,0.3)',
    borderRadius: '3px 0 0 3px',
  }}/>
);

// --------- card frame ---------
// When `completed`, card surface gets a soft magenta tint, content dims, area stripe goes magenta.
const Card = ({ children, showStripe = true, area, completed = false, style = {} }) => (
  <div style={{
    position: 'relative',
    background: completed ? 'color-mix(in srgb, var(--card) 55%, #6E1F8E 45%)' : 'var(--card)',
    borderRadius: 6,
    margin: '4px 8px',
    overflow: 'hidden',
    boxShadow: '0 1px 2px rgba(0,0,0,0.25)',
    opacity: completed ? 0.92 : 1,
    ...style,
  }}>
    {showStripe && (
      <div style={{
        position: 'absolute', left: 0, top: 0, bottom: 0,
        width: 3,
        background: completed ? '#D83AFF' : (AREA_COLORS[area] || 'rgba(255,255,255,0.3)'),
        borderRadius: '3px 0 0 3px',
      }}/>
    )}
    {children}
  </div>
);

// title style helper used by all variants for completed/skipped state
function titleStyle(base, completed, skipped) {
  if (completed || skipped) {
    return { ...base, color: 'rgba(255,255,255,0.55)', textDecoration: 'line-through', textDecorationColor: 'rgba(255,255,255,0.4)' };
  }
  return base;
}

// =========================================================
// V1 — Compact balanced
// Title + area + tiny context icons; date pill top-right; time bar at bottom; points circle inline
// =========================================================
const CardV1 = ({ task }) => {
  const done = task.completed || task.skipped;
  return (
  <Card area={task.area} completed={done}>
    <div style={{ padding: '10px 10px 8px 14px', display: 'flex', gap: 10, alignItems: 'flex-start' }}>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 8 }}>
          <div style={titleStyle({ fontSize: 16, fontWeight: 500, color: 'rgba(255,255,255,0.96)', lineHeight: 1.2, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }, task.completed, task.skipped)}>{task.name}</div>
          {done
            ? <CompletedPill label={task.skipped ? 'Skipped' : 'Completed'} time={task.dateTime || 'just now'}/>
            : (task.dateKind && <DatePill kind={task.dateKind} label={task.dateLabel} time={task.dateTime}/>)}
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 4, fontSize: 11.5, color: 'rgba(255,255,255,0.62)' }}>
          <span>{task.area}</span>
          {task.contexts?.length > 0 && <>
            <span style={{ opacity: 0.4 }}>·</span>
            <span style={{ display: 'inline-flex', gap: 6 }}>
              {task.contexts.map(c => <ContextIcon key={c} name={c}/>)}
            </span>
          </>}
          <span style={{ opacity: 0.4 }}>·</span>
          <span>{fmtTime(task.minutes)}</span>
        </div>
        <div style={{ marginTop: 7 }}>
          <TimeBar minutes={task.minutes}/>
        </div>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8, paddingTop: 1 }}>
        <PointsCircle value={task.points}/>
        <Checkbox checked={done} recurring={task.recurring}/>
      </div>
    </div>
  </Card>
  );
};

// =========================================================
// V2 — Dense informative
// Adds energy dots + recurrence badge + project step bar
// =========================================================
const CardV2 = ({ task }) => {
  const done = task.completed || task.skipped;
  return (
  <Card area={task.area} completed={done}>
    <div style={{ padding: '9px 10px 9px 14px', display: 'flex', gap: 10, alignItems: 'stretch' }}>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <div style={titleStyle({ fontSize: 16, fontWeight: 500, color: '#fff', lineHeight: 1.2, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', flex: 1 }, task.completed, task.skipped)}>{task.name}</div>
          {task.recurring && <RecurringBadge size={12}/>}
          {done
            ? <CompletedPill label={task.skipped ? 'Skipped' : 'Completed'} time={task.dateTime || 'just now'}/>
            : (task.dateKind && <DatePill kind={task.dateKind} label={task.dateLabel} time={task.dateTime}/>)}
        </div>
        {task.project && (
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 4, fontSize: 10.5, color: 'rgba(63,191,122,0.85)', fontWeight: 600, letterSpacing: 0.3, textTransform: 'uppercase' }}>
            <span>{task.project}</span>
            <ProjectDots step={task.projectStep} total={task.projectTotal}/>
            <span style={{ color: 'rgba(255,255,255,0.45)', fontWeight: 500, textTransform: 'none', letterSpacing: 0 }}>{task.projectStep}/{task.projectTotal}</span>
          </div>
        )}
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 5, fontSize: 11.5, color: 'rgba(255,255,255,0.62)' }}>
          <span>{task.area}</span>
          {task.contexts?.length > 0 && (
            <span style={{ display: 'inline-flex', gap: 6 }}>
              {task.contexts.map(c => <ContextIcon key={c} name={c}/>)}
            </span>
          )}
          <span style={{ marginLeft: 'auto', display: 'inline-flex', alignItems: 'center', gap: 8 }}>
            <span style={{ opacity: 0.85, fontVariantNumeric: 'tabular-nums' }}>{fmtTime(task.minutes)}</span>
            <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
              <span style={{ fontSize: 9.5, opacity: 0.7, letterSpacing: 0.4, textTransform: 'uppercase' }}>effort</span>
              <EnergyDots value={task.energy}/>
            </span>
          </span>
        </div>
        <div style={{ marginTop: 6 }}><TimeBar minutes={task.minutes}/></div>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'space-between', gap: 6 }}>
        <PointsCircle value={task.points}/>
        <Checkbox checked={done} recurring={task.recurring}/>
      </div>
    </div>
  </Card>
  );
};

// =========================================================
// V3 — Two-line airy
// Big title; metadata as icon row underneath
// =========================================================
const CardV3 = ({ task }) => {
  const done = task.completed || task.skipped;
  return (
  <Card area={task.area} completed={done}>
    <div style={{ padding: '14px 12px 14px 16px', display: 'flex', gap: 12, alignItems: 'center' }}>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 8 }}>
          <div style={titleStyle({ fontSize: 17, fontWeight: 500, color: '#fff', lineHeight: 1.2, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }, task.completed, task.skipped)}>{task.name}</div>
          {task.recurring && <RecurringBadge size={12}/>}
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginTop: 7, fontSize: 11.5, color: 'rgba(255,255,255,0.6)' }}>
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5 }}>
            <span style={{ width: 6, height: 6, borderRadius: '50%', background: AREA_COLORS[task.area], opacity: 0.9 }}/>
            {task.area}
          </span>
          {task.contexts?.length > 0 && (
            <span style={{ display: 'inline-flex', gap: 7 }}>
              {task.contexts.map(c => <ContextIcon key={c} name={c}/>)}
            </span>
          )}
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}>
            <span style={{ width: 36 }}><TimeBar minutes={task.minutes} height={2}/></span>
            <span>{fmtTime(task.minutes)}</span>
          </span>
        </div>
      </div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
        {done
          ? <CompletedPill label={task.skipped ? 'Skipped' : 'Completed'} time={task.dateTime || 'just now'}/>
          : (task.dateKind && <DatePill kind={task.dateKind} label={task.dateLabel} time={task.dateTime}/>)}
        <PointsCircle value={task.points}/>
        <Checkbox checked={done} recurring={task.recurring}/>
      </div>
    </div>
  </Card>
  );
};

// =========================================================
// V4 — Project header strip
// Shows the project context as a top mini-strip when applicable
// =========================================================
const CardV4 = ({ task }) => {
  const done = task.completed || task.skipped;
  return (
  <Card area={task.area} completed={done}>
    {task.project && (
      <div style={{
        background: 'rgba(63,191,122,0.10)',
        borderBottom: '1px solid rgba(63,191,122,0.20)',
        padding: '5px 10px 5px 16px',
        display: 'flex', alignItems: 'center', gap: 10,
        fontSize: 10.5, color: 'rgba(200,255,220,0.85)',
        textTransform: 'uppercase', letterSpacing: 0.5, fontWeight: 600,
      }}>
        <span style={{ flex: 1, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{task.project}</span>
        <span style={{ display: 'flex', gap: 2 }}>
          {Array.from({length: task.projectTotal}).map((_, i) => (
            <span key={i} style={{
              width: 14, height: 3, borderRadius: 1,
              background: i < task.projectStep ? '#3FBF7A' : 'rgba(255,255,255,0.18)',
            }}/>
          ))}
        </span>
        <span style={{ color: 'rgba(255,255,255,0.6)', fontWeight: 500 }}>Step {task.projectStep}/{task.projectTotal}</span>
      </div>
    )}
    <div style={{ padding: '10px 10px 9px 14px', display: 'flex', gap: 10, alignItems: 'flex-start' }}>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, justifyContent: 'space-between' }}>
          <div style={titleStyle({ fontSize: 16, fontWeight: 500, color: '#fff', lineHeight: 1.2, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }, task.completed, task.skipped)}>{task.name}</div>
          {done
            ? <CompletedPill label={task.skipped ? 'Skipped' : 'Completed'} time={task.dateTime || 'just now'}/>
            : (task.dateKind && <DatePill kind={task.dateKind} label={task.dateLabel} time={task.dateTime}/>)}
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 4, fontSize: 11.5, color: 'rgba(255,255,255,0.6)' }}>
          <span>{task.area}</span>
          {task.contexts?.length > 0 && <>
            <span style={{ opacity: 0.4 }}>·</span>
            <span style={{ display: 'inline-flex', gap: 6 }}>
              {task.contexts.map(c => <ContextIcon key={c} name={c}/>)}
            </span>
          </>}
          <span style={{ opacity: 0.4 }}>·</span>
          <span>{fmtTime(task.minutes)}</span>
        </div>
        <div style={{ marginTop: 7 }}><TimeBar minutes={task.minutes}/></div>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
        <PointsCircle value={task.points}/>
        <Checkbox checked={done} recurring={task.recurring}/>
      </div>
    </div>
  </Card>
  );
};

// =========================================================
// V5 — Vertical time visualization
// Tall left column shows time as a filled vertical bar with tick marks
// =========================================================
const CardV5 = ({ task }) => {
  const f = timeFraction(task.minutes);
  const done = task.completed || task.skipped;
  return (
    <Card area={task.area} showStripe={false} completed={done}>
      <div style={{ display: 'flex', alignItems: 'stretch', gap: 0 }}>
        {/* Left: vertical time visualizer */}
        <div style={{
          width: 36, padding: '8px 0 8px 8px',
          display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
          borderRight: '1px solid rgba(255,255,255,0.06)',
        }}>
          <div style={{
            position: 'relative', width: 4, height: 44,
            background: 'rgba(255,255,255,0.08)', borderRadius: 4, overflow: 'hidden',
          }}>
            <div style={{
              position: 'absolute', bottom: 0, left: 0, width: '100%',
              height: `${f * 100}%`, background: AREA_COLORS[task.area] || 'rgba(179,181,221,0.85)',
              borderRadius: 4,
            }}/>
            {/* tick marks at 30m, 1h, 4h, 1d */}
            {[0.165, 0.275, 0.46, 0.69].map((p, i) => (
              <div key={i} style={{ position: 'absolute', left: 0, right: 0, bottom: `${p*100}%`, height: 1, background: 'rgba(255,255,255,0.18)' }}/>
            ))}
          </div>
          <span style={{ fontSize: 9.5, color: 'rgba(255,255,255,0.6)', fontWeight: 600 }}>{fmtTime(task.minutes)}</span>
        </div>

        <div style={{ flex: 1, minWidth: 0, padding: '10px 10px 10px 12px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, justifyContent: 'space-between' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 6, minWidth: 0 }}>
              <div style={titleStyle({ fontSize: 16, fontWeight: 500, color: '#fff', lineHeight: 1.2, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }, task.completed, task.skipped)}>{task.name}</div>
              {task.recurring && <RecurringBadge size={12}/>}
            </div>
            {done
              ? <CompletedPill label={task.skipped ? 'Skipped' : 'Completed'} time={task.dateTime || 'just now'}/>
              : (task.dateKind && <DatePill kind={task.dateKind} label={task.dateLabel} time={task.dateTime}/>)}
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginTop: 5, fontSize: 11.5, color: 'rgba(255,255,255,0.62)' }}>
            <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5 }}>
              <span style={{ width: 6, height: 6, borderRadius: '50%', background: AREA_COLORS[task.area] }}/>
              {task.area}
            </span>
            {task.contexts?.length > 0 && (
              <span style={{ display: 'inline-flex', gap: 7 }}>
                {task.contexts.map(c => <ContextIcon key={c} name={c}/>)}
              </span>
            )}
            {task.project && (
              <span style={{ marginLeft: 'auto', color: 'rgba(63,191,122,0.85)', fontWeight: 600, fontSize: 10.5, textTransform: 'uppercase', letterSpacing: 0.4, display: 'inline-flex', alignItems: 'center', gap: 5 }}>
                {task.project} {task.projectStep}/{task.projectTotal}
              </span>
            )}
          </div>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'space-between', padding: '10px 10px 10px 4px', gap: 8 }}>
          <PointsCircle value={task.points}/>
          <Checkbox checked={done} recurring={task.recurring}/>
        </div>
      </div>
    </Card>
  );
};

// =========================================================
// V6 — Rich kitchen-sink card (every field on display)
// =========================================================
const CardV6 = ({ task }) => {
  const done = task.completed || task.skipped;
  return (
  <Card area={task.area} completed={done}>
    <div style={{ padding: '10px 10px 10px 14px', display: 'flex', gap: 10, alignItems: 'flex-start' }}>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, justifyContent: 'space-between' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, minWidth: 0 }}>
            <div style={titleStyle({ fontSize: 16, fontWeight: 500, color: '#fff', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', lineHeight: 1.2 }, task.completed, task.skipped)}>{task.name}</div>
            {task.recurring && <RecurringBadge size={12}/>}
          </div>
          {done
            ? <CompletedPill label={task.skipped ? 'Skipped' : 'Completed'} time={task.dateTime || 'just now'}/>
            : (task.dateKind && <DatePill kind={task.dateKind} label={task.dateLabel} time={task.dateTime}/>)}
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 6, fontSize: 11.5, color: 'rgba(255,255,255,0.62)' }}>
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5 }}>
            <span style={{ width: 6, height: 6, borderRadius: '50%', background: AREA_COLORS[task.area] }}/>
            {task.area}
          </span>
          {task.contexts?.length > 0 && (
            <span style={{ display: 'inline-flex', gap: 7 }}>
              {task.contexts.map(c => <ContextIcon key={c} name={c}/>)}
            </span>
          )}
          <span style={{ marginLeft: 'auto', display: 'inline-flex', alignItems: 'center', gap: 8 }}>
            <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
              <span style={{ fontSize: 9.5, opacity: 0.75, letterSpacing: 0.4, textTransform: 'uppercase' }}>effort</span>
              <EnergyDots value={task.energy}/>
            </span>
            <span style={{ opacity: 0.5 }}>·</span>
            <span>{fmtTime(task.minutes)}</span>
          </span>
        </div>

        <div style={{ marginTop: 7, display: 'flex', alignItems: 'center', gap: 10 }}>
          <div style={{ flex: 1 }}><TimeBar minutes={task.minutes}/></div>
        </div>

        {task.project && (
          <div style={{ marginTop: 7, padding: '5px 8px', borderRadius: 4, background: 'rgba(63,191,122,0.08)', border: '1px solid rgba(63,191,122,0.18)', display: 'flex', alignItems: 'center', gap: 8, fontSize: 10.5 }}>
            <span style={{ color: 'rgba(200,255,220,0.9)', fontWeight: 600, textTransform: 'uppercase', letterSpacing: 0.3, flex: 1, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{task.project}</span>
            <span style={{ display: 'flex', gap: 3 }}>
              {Array.from({length: task.projectTotal}).map((_, i) => (
                <span key={i} style={{
                  width: 4, height: 4, borderRadius: '50%',
                  background: i < task.projectStep ? '#3FBF7A' : 'rgba(255,255,255,0.22)',
                }}/>
              ))}
            </span>
            <span style={{ color: 'rgba(255,255,255,0.6)', fontWeight: 500 }}>{task.projectStep}/{task.projectTotal}</span>
          </div>
        )}
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8, paddingTop: 1 }}>
        <PointsCircle value={task.points}/>
        <Checkbox checked={done} recurring={task.recurring}/>
      </div>
    </div>
  </Card>
  );
};

// =========================================================
// V7 — Refined (combines user's preferred elements)
//   • V1 spacing
//   • Right-aligned time + tiny time bar (V2-style cluster)
//   • Area color dot next to area name (V3)
//   • V4-style project header strip with dashed segments
// =========================================================
const CardV7 = ({ task }) => {
  const done = task.completed || task.skipped;
  return (
  <Card area={task.area} completed={done}>
    {task.project && (
      <div style={{
        background: 'rgba(63,191,122,0.12)',
        borderBottom: '1px solid rgba(63,191,122,0.22)',
        padding: '5px 10px 5px 16px',
        display: 'flex', alignItems: 'center', gap: 10,
        fontSize: 10.5, color: 'rgba(200,255,220,0.92)',
        textTransform: 'uppercase', letterSpacing: 0.5, fontWeight: 600,
      }}>
        <span style={{ flex: 1, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{task.project}</span>
        <span style={{ display: 'flex', gap: 2 }}>
          {Array.from({length: task.projectTotal}).map((_, i) => (
            <span key={i} style={{
              width: 14, height: 3, borderRadius: 1,
              background: i < task.projectStep ? '#3FBF7A' : 'rgba(255,255,255,0.18)',
            }}/>
          ))}
        </span>
        <span style={{ color: 'rgba(255,255,255,0.6)', fontWeight: 500 }}>Step {task.projectStep}/{task.projectTotal}</span>
      </div>
    )}
    <div style={{ padding: '10px 10px 9px 14px', display: 'flex', gap: 10, alignItems: 'flex-start' }}>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 8 }}>
          <div style={titleStyle({ fontSize: 16, fontWeight: 500, color: 'rgba(255,255,255,0.96)', lineHeight: 1.2, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }, task.completed, task.skipped)}>{task.name}</div>
          {done
            ? <CompletedPill label={task.skipped ? 'Skipped' : 'Completed'} time={task.dateTime || 'just now'}/>
            : (task.dateKind && <DatePill kind={task.dateKind} label={task.dateLabel} time={task.dateTime}/>)}
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 5, fontSize: 11.5, color: 'rgba(255,255,255,0.62)' }}>
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5 }}>
            <span style={{ width: 6, height: 6, borderRadius: '50%', background: AREA_COLORS[task.area], opacity: 0.95 }}/>
            {task.area}
          </span>
          {task.contexts?.length > 0 && (
            <span style={{ display: 'inline-flex', gap: 6 }}>
              {task.contexts.map(c => <ContextIcon key={c} name={c}/>)}
            </span>
          )}
          <span style={{ marginLeft: 'auto', display: 'inline-flex', alignItems: 'center', gap: 8 }}>
            <span style={{ width: 40 }}><TimeBar minutes={task.minutes} height={2}/></span>
            <span style={{ opacity: 0.85, fontVariantNumeric: 'tabular-nums' }}>{fmtTime(task.minutes)}</span>
          </span>
        </div>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8, paddingTop: 1 }}>
        <PointsCircle value={task.points}/>
        <Checkbox checked={done} recurring={task.recurring}/>
      </div>
    </div>
  </Card>
  );
};

// muscle-arm icon for "effort" / intensity
const MuscleIcon = ({ size = 12, color = 'currentColor' }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    {/* Stylized flex/bicep: forearm + flexed bicep curve */}
    <path d="M3 13c2-1 4-1 6 0 1.5.7 2.5 2 3 4 .5 1.5 2 2 3 2 2 0 3-1 3-3"/>
    <path d="M12 13c.8-1 1.2-2.2 1.2-3.5C13.2 7 11 5 8 5"/>
    <circle cx="20" cy="9" r="2"/>
  </svg>
);

window.TMHelpers = window.TMHelpers || {};
window.TMHelpers.MuscleIcon = MuscleIcon;

// =========================================================
// V8 — Refined+ (V7 base, restructured to fix top-heaviness)
//   • Checkbox on the LEFT, vertically centered (clear primary action)
//   • Points pill inline with title (no more stacked top-right column)
//   • Effort: muscle-arm icon + intensity dots in metadata row
//   • Right-aligned time + bar (consistent across cards)
// =========================================================
const PointsChip = ({ value }) => (
  <span style={{
    display: 'inline-flex', alignItems: 'center', gap: 3,
    padding: '2px 7px', borderRadius: 999,
    background: 'rgba(255,206,128,0.15)',
    border: '1px solid rgba(255,206,128,0.35)',
    color: '#FFE0AC',
    fontSize: 11, fontWeight: 700, letterSpacing: 0.2,
    fontVariantNumeric: 'tabular-nums',
    flexShrink: 0,
  }}>
    <span style={{ fontSize: 9.5, opacity: 0.75, fontWeight: 600 }}>★</span>
    {value}
  </span>
);

const CardV8 = ({ task }) => {
  const done = task.completed || task.skipped;
  return (
  <Card area={task.area} completed={done}>
    {task.project && (
      <div style={{
        background: 'rgba(63,191,122,0.12)',
        borderBottom: '1px solid rgba(63,191,122,0.22)',
        padding: '5px 10px 5px 14px',
        display: 'flex', alignItems: 'center', gap: 10,
        fontSize: 10.5, color: 'rgba(200,255,220,0.92)',
        textTransform: 'uppercase', letterSpacing: 0.5, fontWeight: 600,
      }}>
        <span style={{ flex: 1, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{task.project}</span>
        <span style={{ display: 'flex', gap: 2 }}>
          {Array.from({length: task.projectTotal}).map((_, i) => (
            <span key={i} style={{
              width: 14, height: 3, borderRadius: 1,
              background: i < task.projectStep ? '#3FBF7A' : 'rgba(255,255,255,0.18)',
            }}/>
          ))}
        </span>
        <span style={{ color: 'rgba(255,255,255,0.6)', fontWeight: 500 }}>Step {task.projectStep}/{task.projectTotal}</span>
      </div>
    )}
    <div style={{ padding: '12px 12px 11px 14px', display: 'flex', gap: 12, alignItems: 'center' }}>
      <Checkbox checked={done} recurring={task.recurring}/>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <div style={titleStyle({ fontSize: 16, fontWeight: 500, color: 'rgba(255,255,255,0.96)', lineHeight: 1.25, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', flex: 1 }, task.completed, task.skipped)}>{task.name}</div>
          {task.recurring && <RecurringBadge size={12}/>}
          <PointsChip value={task.points}/>
          {done
            ? <CompletedPill label={task.skipped ? 'Skipped' : 'Completed'} time={task.dateTime || 'just now'}/>
            : (task.dateKind && <DatePill kind={task.dateKind} label={task.dateLabel} time={task.dateTime}/>)}
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginTop: 5, fontSize: 11.5, color: 'rgba(255,255,255,0.62)' }}>
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5 }}>
            <span style={{ width: 6, height: 6, borderRadius: '50%', background: AREA_COLORS[task.area], opacity: 0.95 }}/>
            {task.area}
          </span>
          {task.contexts?.length > 0 && (
            <span style={{ display: 'inline-flex', gap: 6 }}>
              {task.contexts.map(c => <ContextIcon key={c} name={c}/>)}
            </span>
          )}
          {task.energy != null && (
            <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, color: 'rgba(255,206,128,0.85)' }} title="Intensity">
              <MuscleIcon size={13}/>
              <EnergyDots value={task.energy}/>
            </span>
          )}
          <span style={{ marginLeft: 'auto', display: 'inline-flex', alignItems: 'center', gap: 8 }}>
            <span style={{ width: 40 }}><TimeBar minutes={task.minutes} height={2}/></span>
            <span style={{ opacity: 0.85, fontVariantNumeric: 'tabular-nums' }}>{fmtTime(task.minutes)}</span>
          </span>
        </div>
      </div>
    </div>
  </Card>
  );
};

// Priority indicator: 5-segment bar (filled segments = priority level)
const PriorityBar = ({ value, max = 5 }) => {
  // color shifts a touch warmer as priority climbs
  const color = value >= 4 ? 'rgba(255,160,140,0.95)' : value >= 3 ? 'rgba(255,206,128,0.9)' : 'rgba(179,181,221,0.85)';
  return (
    <div style={{ display: 'inline-flex', gap: 2, alignItems: 'center' }} title={`Priority ${value}/${max}`}>
      {Array.from({length: max}).map((_, i) => (
        <span key={i} style={{
          width: 5, height: 8, borderRadius: 1,
          background: i < value ? color : 'rgba(255,255,255,0.14)',
        }}/>
      ))}
    </div>
  );
};

// =========================================================
// V9 — Refined++ with expandable detail panel
//   Tap card body → expand inline (replaces the separate detail screen).
//   Drops the duplicate recurring badge next to the title; the checkbox
//   already shows the recurring cue. Expanded section shows all 4 dates,
//   full contexts (text), repeat, notes.
// =========================================================

// Format a date like "May 6th" / "a day from now" on two lines
const ExpandedRow = ({ label, value, sub, color }) => (
  <div style={{
    display: 'flex', alignItems: 'flex-start', gap: 10,
    padding: '7px 0',
    borderTop: '1px solid rgba(255,255,255,0.06)',
  }}>
    <span style={{ width: 60, flexShrink: 0, fontSize: 10.5, textTransform: 'uppercase', letterSpacing: 0.4, color: 'rgba(255,255,255,0.45)', fontWeight: 600, paddingTop: 1 }}>{label}</span>
    <span style={{ flex: 1, fontSize: 12.5, color: color || 'rgba(255,255,255,0.88)', lineHeight: 1.35 }}>
      <div>{value}</div>
      {sub && <div style={{ color: 'rgba(255,255,255,0.45)', fontSize: 11, marginTop: 1 }}>{sub}</div>}
    </span>
  </div>
);

// Context pill: small icon (if available) + label
const ContextPill = ({ name }) => (
  <span style={{
    display: 'inline-flex', alignItems: 'center', gap: 5,
    padding: '3px 9px 3px 7px',
    borderRadius: 999,
    background: 'rgba(255,255,255,0.07)',
    border: '1px solid rgba(255,255,255,0.14)',
    color: 'rgba(255,255,255,0.88)',
    fontSize: 11.5, fontWeight: 500,
  }}>
    <ContextIcon name={name} size={12}/>
    {CONTEXT_LABELS[name] || name}
  </span>
);

// Pencil/edit icon button — matches the pink FAB from the original detail screen
const EditButton = ({ onClick }) => (
  <button
    onClick={(e) => { e.stopPropagation(); onClick && onClick(); }}
    style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      padding: '6px 12px 6px 10px',
      borderRadius: 999,
      background: '#D83AFF',
      border: 'none',
      color: '#fff',
      fontSize: 12, fontWeight: 600,
      cursor: 'pointer',
      boxShadow: '0 2px 8px rgba(216,58,255,0.35)',
    }}
  >
    <svg width="13" height="13" viewBox="0 0 16 16" fill="none" stroke="#fff" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M11.5 2.5l2 2L5 13l-3 .5.5-3 9-8z"/>
    </svg>
    Edit
  </button>
);

const DATE_LABELS = [
  { key: 'start',  label: 'Start',  toneKey: 'start' },
  { key: 'target', label: 'Target', toneKey: 'target' },
  { key: 'urgent', label: 'Urgent', toneKey: 'urgent' },
  { key: 'due',    label: 'Due',    toneKey: 'due' },
];

const CONTEXT_LABELS = {
  email: 'E-Mail', phone: 'Phone', people: 'People', errand: 'Errand',
  car: 'Car', home: 'Home', computer: 'Computer',
  shopping: 'Shopping', reading: 'Reading', writing: 'Writing',
  outdoors: 'Outdoors', anywhere: 'Anywhere',
};

const CardV9 = ({ task }) => {
  const done = task.completed || task.skipped;
  const [expanded, setExpanded] = React.useState(!!task.defaultExpanded);
  const dates = task.dates || {};
  const hasAnyExpanded = task.notes || task.repeat || Object.keys(dates).length > 0 || (task.contexts && task.contexts.length > 0);
  return (
  <Card area={task.area} completed={done}>
    {task.project && (
      <div style={{
        background: 'rgba(63,191,122,0.12)',
        borderBottom: '1px solid rgba(63,191,122,0.22)',
        padding: '5px 14px 5px 14px',
        display: 'flex', alignItems: 'center', gap: 10,
        fontSize: 10.5, color: 'rgba(200,255,220,0.92)',
        textTransform: 'uppercase', letterSpacing: 0.5, fontWeight: 600,
      }}>
        <span style={{ flex: 1, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{task.project}</span>
        <span style={{ display: 'flex', gap: 2 }}>
          {Array.from({length: task.projectTotal}).map((_, i) => (
            <span key={i} style={{
              width: 14, height: 3, borderRadius: 1,
              background: i < task.projectStep ? '#3FBF7A' : 'rgba(255,255,255,0.18)',
            }}/>
          ))}
        </span>
        <span style={{ color: 'rgba(255,255,255,0.6)', fontWeight: 500 }}>Step {task.projectStep}/{task.projectTotal}</span>
      </div>
    )}
    <div style={{ padding: '12px 12px 11px 14px' }}>
      <div style={{ display: 'flex', gap: 12, alignItems: 'flex-start' }}>
        <div
          onClick={() => hasAnyExpanded && setExpanded(e => !e)}
          style={{ flex: 1, minWidth: 0, cursor: hasAnyExpanded ? 'pointer' : 'default' }}
        >
          {/* Row 1: title + date pill (no duplicate recurring icon — checkbox shows it) */}
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <div style={titleStyle({ fontSize: 16, fontWeight: 500, color: 'rgba(255,255,255,0.96)', lineHeight: 1.25, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', flex: 1 }, task.completed, task.skipped)}>{task.name}</div>
            {done
              ? <CompletedPill label={task.skipped ? 'Skipped' : 'Completed'} time={task.dateTime || 'just now'}/>
              : (task.dateKind && <DatePill kind={task.dateKind} label={task.dateLabel} time={task.dateTime}/>)}
          </div>
          {/* Row 2: area + contexts | (right cluster) time + priority + points */}
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginTop: 6, fontSize: 11.5, color: 'rgba(255,255,255,0.62)' }}>
            <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5, minWidth: 0, overflow: 'hidden' }}>
              <span style={{ width: 6, height: 6, borderRadius: '50%', background: AREA_COLORS[task.area], opacity: 0.95, flexShrink: 0 }}/>
              <span style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{task.area}</span>
            </span>
            {task.contexts?.length > 0 && (
              <span style={{ display: 'inline-flex', gap: 6, flexShrink: 0 }}>
                {task.contexts.slice(0, 3).map(c => <ContextIcon key={c} name={c}/>)}
                {task.contexts.length > 3 && (
                  <span style={{ fontSize: 10, color: 'rgba(255,255,255,0.5)', alignSelf: 'center' }}>+{task.contexts.length - 3}</span>
                )}
              </span>
            )}
            <span style={{ marginLeft: 'auto', display: 'inline-flex', alignItems: 'center', gap: 10, flexShrink: 0 }}>
              <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
                <span style={{ textAlign: 'right', opacity: 0.85, fontVariantNumeric: 'tabular-nums' }}>{fmtTime(task.minutes)}</span>
                <span style={{ width: 40 }}><TimeBar minutes={task.minutes} height={2}/></span>
              </span>
              <PriorityBar value={task.priority || 1}/>
              <span style={{
                minWidth: 22, height: 22, padding: '0 6px',
                borderRadius: 999,
                border: '1px solid rgba(255,255,255,0.32)',
                background: 'rgba(255,255,255,0.06)',
                color: 'rgba(255,255,255,0.92)',
                display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
                fontSize: 11, fontWeight: 700, letterSpacing: 0.2,
                fontVariantNumeric: 'tabular-nums', flexShrink: 0,
              }}>{task.points}</span>
            </span>
          </div>
        </div>
        {/* Checkbox vertically centered on the two header rows (~ rows are ~ 41px tall total → 9px top offset) */}
        <div style={{ paddingTop: 9 }}>
          <Checkbox checked={done} recurring={task.recurring}/>
        </div>
      </div>

      {/* Expanded section — spans full card width */}
      {expanded && hasAnyExpanded && (
        <div
          onClick={() => setExpanded(false)}
          style={{ marginTop: 10, paddingTop: 4, cursor: 'pointer' }}
        >
          {DATE_LABELS.some(d => dates[d.key]) && (
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0 16px' }}>
              {DATE_LABELS.map(d => {
                const v = dates[d.key];
                if (!v) return null;
                const tone = DATE_TONES[d.toneKey];
                return (
                  <ExpandedRow
                    key={d.key}
                    label={d.label}
                    value={v.date}
                    sub={v.relative}
                    color={tone?.fg}
                  />
                );
              })}
            </div>
          )}
          {task.contexts?.length > 0 && (
            <div style={{
              display: 'flex', alignItems: 'flex-start', gap: 10,
              padding: '7px 0',
              borderTop: '1px solid rgba(255,255,255,0.06)',
            }}>
              <span style={{ width: 60, flexShrink: 0, fontSize: 10.5, textTransform: 'uppercase', letterSpacing: 0.4, color: 'rgba(255,255,255,0.45)', fontWeight: 600, paddingTop: 4 }}>Contexts</span>
              <div style={{ flex: 1, display: 'flex', flexWrap: 'wrap', gap: 5 }}>
                {task.contexts.map(c => <ContextPill key={c} name={c}/>)}
              </div>
            </div>
          )}
          {task.repeat && (
            <ExpandedRow label="Repeat" value={task.repeat} />
          )}
          {task.notes && (
            <ExpandedRow label="Notes" value={task.notes} />
          )}
          {/* Footer: edit button */}
          <div style={{
            display: 'flex', justifyContent: 'flex-end',
            paddingTop: 10,
            borderTop: '1px solid rgba(255,255,255,0.06)',
            marginTop: 4,
          }}>
            <EditButton onClick={() => {}}/>
          </div>
        </div>
      )}
    </div>
  </Card>
  );
};

window.TMCards = { CardV1, CardV2, CardV3, CardV4, CardV5, CardV6, CardV7, CardV8, CardV9 };
window.TMHelpers = { AREA_COLORS, DATE_TONES, fmtTime, timeFraction, ContextIcon, RecurringBadge, Checkbox, DatePill, PointsCircle, TimeBar, EnergyDots, ProjectDots };
