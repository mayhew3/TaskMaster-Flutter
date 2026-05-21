// =========================================================
// Edit screen — Direction C (full-screen, redesigned)
// Reflects user feedback:
//   - Background matches card brand-blue (cardDarkness 0.08 baked in)
//   - Area: single-select via popup picker (saves vertical space)
//   - Contexts: multi-select via popup picker (selections shown as inline pills)
//   - Priority/Points/Length: segmented bars (one row each)
//   - Dates: compact list of 4 toggleable rows, calendar popup on tap
//   - Repeat unit: 2-row pill grid (Days/Weeks/Months/Years)
//   - Repeat anchor: ["Completed Date", "Schedule Date"]
// =========================================================

const { AREA_COLORS, DATE_TONES, ContextIcon, fmtTime, RecurringBadge } = window.TMHelpers;

// Card brand color (matches cards.jsx with cardDarkness 0.08)
const EDITOR_BG = 'rgb(40, 107, 181)';
const EDITOR_BG_TOP = 'rgb(46, 124, 209)'; // slightly lighter top for header glow

// ---------- shared editor widgets ----------

const FieldLabel = ({ children, hint, action }) => (
  <div style={{
    fontSize: 10.5, textTransform: 'uppercase', letterSpacing: 0.5,
    color: 'rgba(255,255,255,0.55)', fontWeight: 600,
    display: 'flex', alignItems: 'baseline', gap: 8,
    marginBottom: 7,
  }}>
    <span>{children}</span>
    {hint && <span style={{ textTransform: 'none', letterSpacing: 0, color: 'rgba(255,255,255,0.45)', fontWeight: 400 }}>{hint}</span>}
    <span style={{ flex: 1 }}/>
    {action}
  </div>
);

const InlineText = ({ value, placeholder, fontSize = 16, fontWeight = 500, multiline = false }) => {
  const Tag = multiline ? 'textarea' : 'input';
  return (
    <Tag
      defaultValue={value}
      placeholder={placeholder}
      rows={multiline ? 3 : undefined}
      style={{
        width: '100%', boxSizing: 'border-box',
        background: 'rgba(255,255,255,0.06)',
        border: '1px solid rgba(255,255,255,0.10)',
        borderRadius: 10,
        padding: '11px 13px',
        color: '#fff',
        fontSize, fontWeight,
        fontFamily: 'inherit',
        resize: multiline ? 'vertical' : 'none',
        outline: 'none',
        minHeight: multiline ? 80 : undefined,
        lineHeight: 1.4,
      }}
    />
  );
};

// Segmented level bar
const SegmentedBar = ({ value, max = 5, onChange, accent = 'brand', allowZero = true, labels = null }) => {
  const filledColor = (i) => {
    if (accent === 'priority') {
      return i >= 4 ? 'rgba(255,160,140,0.95)' : i >= 3 ? 'rgba(255,206,128,0.95)' : 'rgba(179,181,221,0.95)';
    }
    if (accent === 'points') return 'rgba(255,255,255,0.85)';
    return 'rgba(143,184,255,0.95)';
  };
  return (
    <div style={{ display: 'flex', gap: 4 }}>
      {Array.from({ length: max }).map((_, i) => {
        const filled = i < value;
        return (
          <button
            key={i}
            onClick={() => onChange && onChange(allowZero && i + 1 === value ? 0 : i + 1)}
            style={{
              flex: 1, height: 32, padding: 0,
              borderRadius: 6,
              border: filled ? '1px solid rgba(255,255,255,0)' : '1px solid rgba(255,255,255,0.16)',
              background: filled ? filledColor(i) : 'rgba(255,255,255,0.05)',
              color: filled ? 'rgba(20,30,60,0.9)' : 'rgba(255,255,255,0.55)',
              fontSize: 12, fontWeight: 700, cursor: 'pointer',
              fontVariantNumeric: 'tabular-nums',
              transition: 'background 120ms',
            }}
          >{labels ? labels[i] : (i + 1)}</button>
        );
      })}
    </div>
  );
};

// Length picker — semantic time buckets
const LengthPicker = ({ minutes, onChange }) => {
  const buckets = [
    { m: 5, label: '5m' }, { m: 15, label: '15m' }, { m: 30, label: '30m' }, { m: 60, label: '1h' },
    { m: 120, label: '2h' }, { m: 240, label: '4h' }, { m: 480, label: '8h' }, { m: 1440, label: '1d' },
  ];
  let activeIdx = 0, bestDelta = Infinity;
  buckets.forEach((b, i) => {
    const d = Math.abs(b.m - minutes);
    if (d < bestDelta) { bestDelta = d; activeIdx = i; }
  });
  return (
    <div style={{ display: 'flex', gap: 3 }}>
      {buckets.map((b, i) => {
        const filled = i === activeIdx;
        return (
          <button key={b.m} onClick={() => onChange && onChange(b.m)} style={{
            flex: 1, height: 32, padding: 0, borderRadius: 6,
            border: filled ? '1px solid rgba(255,255,255,0)' : '1px solid rgba(255,255,255,0.14)',
            background: filled ? 'rgba(143,184,255,0.95)' : 'rgba(255,255,255,0.05)',
            color: filled ? 'rgba(20,30,60,0.92)' : 'rgba(255,255,255,0.6)',
            fontSize: 11, fontWeight: 700, cursor: 'pointer',
          }}>{b.label}</button>
        );
      })}
    </div>
  );
};

// Pill — used for inline display of selections
const Pill = ({ children, color, onRemove, onClick, dashed }) => (
  <span
    onClick={onClick}
    style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      padding: onRemove ? '5px 6px 5px 10px' : '6px 12px 6px 10px',
      borderRadius: 999,
      background: color ? `${color}28` : 'rgba(255,255,255,0.06)',
      border: dashed
        ? '1px dashed rgba(255,255,255,0.25)'
        : (color ? `1px solid ${color}66` : '1px solid rgba(255,255,255,0.14)'),
      color: '#fff',
      fontSize: 12.5, fontWeight: 500,
      cursor: onClick ? 'pointer' : 'default',
    }}
  >
    {color && <span style={{ width: 7, height: 7, borderRadius: '50%', background: color }}/>}
    {children}
    {onRemove && (
      <button
        onClick={(e) => { e.stopPropagation(); onRemove(); }}
        style={{
          background: 'rgba(0,0,0,0.2)', border: 'none', cursor: 'pointer',
          width: 18, height: 18, borderRadius: '50%',
          color: 'rgba(255,255,255,0.7)',
          display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
          padding: 0, fontSize: 14, lineHeight: 1,
        }}
      >×</button>
    )}
  </span>
);

// Add-button pill (icon-only, dashed)
const AddPill = ({ children, onClick }) => (
  <button onClick={onClick} style={{
    display: 'inline-flex', alignItems: 'center', gap: 5,
    padding: '6px 12px 6px 10px',
    borderRadius: 999,
    background: 'transparent',
    border: '1px dashed rgba(255,255,255,0.25)',
    color: 'rgba(255,255,255,0.65)',
    fontSize: 12.5, fontWeight: 500,
    cursor: 'pointer',
  }}>
    <svg width="11" height="11" viewBox="0 0 12 12" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><line x1="6" y1="2" x2="6" y2="10"/><line x1="2" y1="6" x2="10" y2="6"/></svg>
    {children}
  </button>
);

// ---------- popup overlay ----------
const PopupOverlay = ({ title, onClose, children, footer }) => (
  <div style={{
    position: 'absolute', inset: 0,
    background: 'rgba(0,0,0,0.55)',
    backdropFilter: 'blur(6px)',
    display: 'flex', alignItems: 'flex-end', justifyContent: 'center',
    zIndex: 100,
  }}>
    <div style={{
      width: '100%',
      background: 'rgb(36, 50, 80)',
      borderTopLeftRadius: 18, borderTopRightRadius: 18,
      maxHeight: '80%',
      display: 'flex', flexDirection: 'column',
      boxShadow: '0 -8px 30px rgba(0,0,0,0.4)',
      animation: 'tm-rise 220ms ease-out',
    }}>
      <div style={{ display: 'flex', justifyContent: 'center', padding: '8px 0 4px' }}>
        <div style={{ width: 36, height: 4, borderRadius: 2, background: 'rgba(255,255,255,0.2)' }}/>
      </div>
      <div style={{
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        padding: '4px 18px 12px',
        borderBottom: '1px solid rgba(255,255,255,0.06)',
      }}>
        <span style={{ fontSize: 14, fontWeight: 600, color: '#fff' }}>{title}</span>
        <button onClick={onClose} style={{
          background: 'transparent', border: 'none', color: 'rgba(255,255,255,0.7)',
          cursor: 'pointer', fontSize: 13, fontWeight: 600, padding: '4px 8px',
        }}>Done</button>
      </div>
      <div style={{ padding: '14px 18px', overflow: 'auto', flex: 1 }}>{children}</div>
      {footer && (
        <div style={{ padding: '12px 18px 22px', borderTop: '1px solid rgba(255,255,255,0.06)' }}>{footer}</div>
      )}
    </div>
  </div>
);

// ---------- inline "add new" field ----------
const AddNewInline = ({ placeholder, onAdd }) => {
  const [value, setValue] = React.useState('');
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 8,
      padding: '4px 6px 4px 10px',
      borderRadius: 10,
      background: 'rgba(255,255,255,0.04)',
      border: '1px dashed rgba(255,255,255,0.18)',
    }}>
      <svg width="13" height="13" viewBox="0 0 12 12" fill="none" stroke="rgba(255,255,255,0.5)" strokeWidth="2" strokeLinecap="round"><line x1="6" y1="2" x2="6" y2="10"/><line x1="2" y1="6" x2="10" y2="6"/></svg>
      <input
        value={value}
        placeholder={placeholder}
        onChange={(e) => setValue(e.target.value)}
        onKeyDown={(e) => {
          if (e.key === 'Enter' && value.trim()) {
            onAdd(value.trim());
            setValue('');
          }
        }}
        style={{
          flex: 1, background: 'transparent', border: 'none', outline: 'none',
          color: '#fff', fontSize: 14, fontWeight: 500, padding: '8px 0',
          fontFamily: 'inherit',
        }}
      />
      {value.trim() && (
        <button onClick={() => { onAdd(value.trim()); setValue(''); }} style={{
          background: '#D83AFF', border: 'none',
          color: '#fff', fontSize: 12, fontWeight: 700,
          padding: '6px 12px', borderRadius: 8, cursor: 'pointer',
        }}>Add</button>
      )}
    </div>
  );
};

// ---------- area picker popup ----------
const DEFAULT_AREAS = ['Family', 'Maintenance', 'Shopping', 'Hobby', 'Work', 'Friends'];

const AreaPicker = ({ value, options, onChange, onClose, onAddNew }) => (
  <PopupOverlay title="Select area" onClose={onClose}>
    <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
      {options.map(a => {
        const sel = value === a;
        const color = AREA_COLORS[a] || '#9F86FF';
        return (
          <button key={a} onClick={() => onChange(a)} style={{
            display: 'flex', alignItems: 'center', gap: 12,
            padding: '13px 12px', borderRadius: 10,
            background: sel ? 'rgba(143,184,255,0.12)' : 'transparent',
            border: 'none', cursor: 'pointer', textAlign: 'left',
          }}>
            <span style={{ width: 12, height: 12, borderRadius: '50%', background: color }}/>
            <span style={{ flex: 1, color: '#fff', fontSize: 15, fontWeight: 500 }}>{a}</span>
            {sel && (
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="rgba(143,184,255,0.95)" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
            )}
          </button>
        );
      })}
      <div style={{ marginTop: 10 }}>
        <AddNewInline placeholder="Add new area..." onAdd={onAddNew}/>
      </div>
    </div>
  </PopupOverlay>
);

// ---------- contexts picker popup (only unselected) ----------
const DEFAULT_CONTEXTS = [
  { value: 'email',    label: 'E-Mail' },
  { value: 'phone',    label: 'Phone' },
  { value: 'people',   label: 'People' },
  { value: 'errand',   label: 'Errand' },
  { value: 'car',      label: 'Car' },
  { value: 'home',     label: 'Home' },
  { value: 'computer', label: 'Computer' },
  { value: 'shopping', label: 'Shopping' },
  { value: 'reading',  label: 'Reading' },
  { value: 'writing',  label: 'Writing' },
  { value: 'outdoors', label: 'Outdoors' },
  { value: 'anywhere', label: 'Anywhere' },
];

const ContextsPicker = ({ selected, options, onAdd, onAddNew, onClose }) => {
  const remaining = options.filter(o => !selected.includes(o.value));
  return (
    <PopupOverlay title={`Add context${selected.length ? ` · ${selected.length} already selected` : ''}`} onClose={onClose}>
      {remaining.length === 0 ? (
        <div style={{ padding: '20px 4px', color: 'rgba(255,255,255,0.5)', fontSize: 14, textAlign: 'center', fontStyle: 'italic' }}>
          All contexts are already selected.
        </div>
      ) : (
        <div style={{
          display: 'grid',
          gridTemplateColumns: '1fr 1fr',
          gap: 6,
        }}>
          {remaining.map(opt => (
            <button key={opt.value} onClick={() => onAdd(opt.value)} style={{
              display: 'flex', alignItems: 'center', gap: 10,
              padding: '11px 12px', borderRadius: 10,
              background: 'rgba(255,255,255,0.04)',
              border: '1px solid rgba(255,255,255,0.08)',
              cursor: 'pointer', textAlign: 'left',
            }}>
              <span style={{ width: 16, display: 'flex', justifyContent: 'center', flexShrink: 0 }}>
                <ContextIcon name={opt.value} size={14}/>
              </span>
              <span style={{ color: '#fff', fontSize: 13.5, fontWeight: 500 }}>{opt.label}</span>
              <span style={{ flex: 1 }}/>
              <svg width="13" height="13" viewBox="0 0 12 12" fill="none" stroke="rgba(255,255,255,0.5)" strokeWidth="2" strokeLinecap="round"><line x1="6" y1="2" x2="6" y2="10"/><line x1="2" y1="6" x2="10" y2="6"/></svg>
            </button>
          ))}
        </div>
      )}
      <div style={{ marginTop: 14 }}>
        <AddNewInline placeholder="Add new context..." onAdd={onAddNew}/>
      </div>
    </PopupOverlay>
  );
};

// ---------- date picker popup ----------
// Mini calendar grid showing 1 month, with month nav and a "clear" / "set" footer
const DATE_DEFS = {
  start:  { label: 'Start',  toneKey: 'start'  },
  target: { label: 'Target', toneKey: 'target' },
  urgent: { label: 'Urgent', toneKey: 'urgent' },
  due:    { label: 'Due',    toneKey: 'due'    },
};

// ---------- compact dates summary (in form) ----------
const DATE_KEYS = ['start','target','urgent','due'];

const DateSummaryRow = ({ dates, onOpen }) => {
  const setKeys = DATE_KEYS.filter(k => dates[k]);
  return (
    <button onClick={onOpen} style={{
      width: '100%', display: 'flex', alignItems: 'center', gap: 8,
      padding: '12px 14px',
      background: 'rgba(255,255,255,0.05)',
      border: '1px solid rgba(255,255,255,0.10)',
      borderRadius: 10, cursor: 'pointer', textAlign: 'left',
    }}>
      {setKeys.length > 0 ? (
        <>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, flex: 1 }}>
            {setKeys.map(k => {
              const tone = DATE_TONES[k];
              const v = dates[k];
              return (
                <span key={k} style={{
                  display: 'inline-flex', alignItems: 'center', gap: 6,
                  padding: '4px 10px',
                  borderRadius: 999,
                  background: `${tone.fg}1f`,
                  border: `1px solid ${tone.border}`,
                  color: '#fff', fontSize: 12, fontWeight: 500,
                }}>
                  <span style={{ width: 6, height: 6, borderRadius: '50%', background: tone.fg }}/>
                  <span style={{ color: tone.fg, fontWeight: 700, fontSize: 10, textTransform: 'uppercase', letterSpacing: 0.4 }}>
                    {DATE_DEFS[k].label}
                  </span>
                  <span style={{ color: 'rgba(255,255,255,0.9)' }}>{v.date}</span>
                </span>
              );
            })}
          </div>
          <span style={{ color: 'rgba(255,255,255,0.5)', fontSize: 11.5, fontWeight: 500 }}>{setKeys.length}/4</span>
        </>
      ) : (
        <span style={{ flex: 1, color: 'rgba(255,255,255,0.4)', fontSize: 13.5, fontStyle: 'italic' }}>No dates set</span>
      )}
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.5)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
    </button>
  );
};

// ---------- date timeline popup ----------
// Horizontal timeline showing all set dates as markers, with add/remove tools
// for unset date types. Selecting a marker reveals a mini calendar to edit.
const DateTimelinePopup = ({ dates, onChange, onClose }) => {
  const setKeys = DATE_KEYS.filter(k => dates[k]);
  const unsetKeys = DATE_KEYS.filter(k => !dates[k]);
  const [selected, setSelected] = React.useState(setKeys[0] || null);

  // timeline range — pad 4 days on each side of min/max day
  const days = setKeys.map(k => dates[k].day);
  const minDay = days.length ? Math.max(1, Math.min(...days) - 3) : 1;
  const maxDay = days.length ? Math.min(31, Math.max(...days) + 3) : 31;
  const range = maxDay - minDay || 1;
  const dayToPct = (d) => ((d - minDay) / range) * 100;

  // ticks every 7 days within range
  const ticks = [];
  for (let d = Math.ceil(minDay / 7) * 7; d <= maxDay; d += 7) {
    ticks.push(d);
  }
  if (!ticks.includes(minDay)) ticks.unshift(minDay);
  if (!ticks.includes(maxDay)) ticks.push(maxDay);

  // selected detail
  const sel = selected ? dates[selected] : null;
  const selDef = selected ? DATE_DEFS[selected] : null;
  const selTone = selected ? DATE_TONES[selected] : null;

  return (
    <PopupOverlay
      title="Dates"
      onClose={onClose}
      footer={null}
    >
      {/* timeline */}
      <div style={{
        position: 'relative',
        margin: '4px 8px 8px',
        paddingTop: 60,
        paddingBottom: 32,
      }}>
        {/* track */}
        <div style={{
          position: 'absolute', left: 0, right: 0, top: 76,
          height: 2, background: 'rgba(255,255,255,0.12)', borderRadius: 1,
        }}/>
        {/* ticks */}
        {ticks.map(d => (
          <div key={d} style={{
            position: 'absolute', left: `${dayToPct(d)}%`,
            top: 72, transform: 'translateX(-50%)',
            display: 'flex', flexDirection: 'column', alignItems: 'center',
          }}>
            <div style={{ width: 1, height: 10, background: 'rgba(255,255,255,0.18)' }}/>
            <div style={{
              fontSize: 10, color: 'rgba(255,255,255,0.45)', marginTop: 4,
              fontVariantNumeric: 'tabular-nums', whiteSpace: 'nowrap',
            }}>May {d}</div>
          </div>
        ))}

        {/* markers */}
        {setKeys.map(k => {
          const v = dates[k];
          const tone = DATE_TONES[k];
          const isSel = selected === k;
          return (
            <div key={k} style={{
              position: 'absolute', left: `${dayToPct(v.day)}%`,
              top: 0, height: 76,
              transform: 'translateX(-50%)',
              display: 'flex', flexDirection: 'column', alignItems: 'center',
              cursor: 'pointer',
            }} onClick={() => setSelected(k)}>
              {/* label flag */}
              <div style={{
                background: isSel ? tone.fg : `${tone.fg}24`,
                border: `1px solid ${tone.border}`,
                borderRadius: 8,
                padding: '4px 8px',
                fontSize: 10.5, fontWeight: 700,
                color: isSel ? 'rgba(20,30,60,0.95)' : tone.fg,
                textTransform: 'uppercase', letterSpacing: 0.4,
                whiteSpace: 'nowrap',
                boxShadow: isSel ? `0 4px 14px ${tone.fg}55` : 'none',
              }}>{DATE_DEFS[k].label}</div>
              <div style={{
                fontSize: 11, color: 'rgba(255,255,255,0.8)',
                marginTop: 3, fontVariantNumeric: 'tabular-nums',
                whiteSpace: 'nowrap',
              }}>{v.date}</div>
              {/* connector line */}
              <div style={{ flex: 1, width: 1.5, background: tone.fg, marginTop: 3 }}/>
              {/* dot on track */}
              <div style={{
                position: 'absolute', bottom: -1,
                width: isSel ? 16 : 12, height: isSel ? 16 : 12,
                borderRadius: '50%',
                background: tone.fg,
                border: '2px solid rgb(36,50,80)',
                boxShadow: isSel ? `0 0 0 3px ${tone.fg}55` : 'none',
              }}/>
            </div>
          );
        })}
      </div>

      {/* unset dates row */}
      {unsetKeys.length > 0 && (
        <div style={{
          marginTop: 4, padding: '12px 4px 6px',
          borderTop: '1px solid rgba(255,255,255,0.06)',
        }}>
          <div style={{
            fontSize: 10.5, textTransform: 'uppercase', letterSpacing: 0.5,
            color: 'rgba(255,255,255,0.5)', fontWeight: 600, marginBottom: 8,
          }}>Add a date</div>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
            {unsetKeys.map(k => {
              const tone = DATE_TONES[k];
              return (
                <button key={k} onClick={() => {
                  // mock: add a default date
                  const defaultDays = { start: 1, target: 6, urgent: 14, due: 21 };
                  const d = defaultDays[k];
                  onChange({
                    ...dates,
                    [k]: { date: `May ${d}`, day: d, relative: 'in soon' }
                  });
                  setSelected(k);
                }} style={{
                  display: 'inline-flex', alignItems: 'center', gap: 6,
                  padding: '7px 12px',
                  borderRadius: 999,
                  background: `${tone.fg}10`,
                  border: `1px dashed ${tone.fg}66`,
                  color: tone.fg, fontSize: 12, fontWeight: 600,
                  cursor: 'pointer',
                }}>
                  <svg width="11" height="11" viewBox="0 0 12 12" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"><line x1="6" y1="2" x2="6" y2="10"/><line x1="2" y1="6" x2="10" y2="6"/></svg>
                  {DATE_DEFS[k].label}
                </button>
              );
            })}
          </div>
        </div>
      )}

      {/* selected detail — mini calendar + remove */}
      {sel && (
        <div style={{
          marginTop: 14, paddingTop: 14,
          borderTop: '1px solid rgba(255,255,255,0.06)',
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 12 }}>
            <span style={{ width: 10, height: 10, borderRadius: '50%', background: selTone.fg }}/>
            <span style={{ fontSize: 13, fontWeight: 700, color: '#fff' }}>{selDef.label} date</span>
            <span style={{ fontSize: 12.5, color: 'rgba(255,255,255,0.6)' }}>· {sel.date}</span>
            <span style={{ flex: 1 }}/>
            <button onClick={() => {
              const next = { ...dates };
              delete next[selected];
              onChange(next);
              const remaining = DATE_KEYS.filter(k => next[k]);
              setSelected(remaining[0] || null);
            }} style={{
              display: 'inline-flex', alignItems: 'center', gap: 5,
              background: 'rgba(255,120,120,0.12)',
              border: '1px solid rgba(255,120,120,0.3)',
              color: 'rgba(255,180,180,0.95)',
              fontSize: 11.5, fontWeight: 600,
              padding: '5px 10px', borderRadius: 999,
              cursor: 'pointer',
            }}>
              <svg width="10" height="10" viewBox="0 0 12 12" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><line x1="2.5" y1="2.5" x2="9.5" y2="9.5"/><line x1="9.5" y1="2.5" x2="2.5" y2="9.5"/></svg>
              Remove
            </button>
          </div>
          <MiniMonth selectedDay={sel.day} accent={selTone.fg}/>
          {/* time */}
          <div style={{ marginTop: 12 }}>
            <div style={{ fontSize: 10.5, textTransform: 'uppercase', letterSpacing: 0.5, color: 'rgba(255,255,255,0.5)', fontWeight: 600, marginBottom: 6 }}>Time</div>
            <div style={{ display: 'flex', gap: 5 }}>
              {['9 AM','12 PM','2 PM','5 PM','All day'].map((t, i) => (
                <button key={t} style={{
                  flex: 1, padding: '8px 4px', borderRadius: 8,
                  background: i === 2 ? `${selTone.fg}25` : 'rgba(255,255,255,0.04)',
                  border: i === 2 ? `1px solid ${selTone.border}` : '1px solid rgba(255,255,255,0.08)',
                  color: '#fff', fontSize: 11, fontWeight: 500, cursor: 'pointer',
                }}>{t}</button>
              ))}
            </div>
          </div>
        </div>
      )}
    </PopupOverlay>
  );
};

const MiniMonth = ({ selectedDay, accent }) => {
  const days = Array.from({ length: 31 }, (_, i) => i + 1);
  const blanks = 4;
  return (
    <div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
        <span style={{ fontSize: 12, color: 'rgba(255,255,255,0.7)', fontWeight: 600 }}>May 2026</span>
        <span style={{ flex: 1 }}/>
        <button style={{ background: 'transparent', border: 'none', color: 'rgba(255,255,255,0.5)', cursor: 'pointer', padding: 2 }}>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
        </button>
        <button style={{ background: 'transparent', border: 'none', color: 'rgba(255,255,255,0.5)', cursor: 'pointer', padding: 2 }}>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
        </button>
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7,1fr)', gap: 3, marginBottom: 4 }}>
        {['S','M','T','W','T','F','S'].map((d, i) => (
          <div key={i} style={{ textAlign: 'center', fontSize: 10, color: 'rgba(255,255,255,0.4)', fontWeight: 600 }}>{d}</div>
        ))}
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7,1fr)', gap: 3 }}>
        {Array.from({ length: blanks }).map((_, i) => <div key={'b'+i}/>)}
        {days.map(d => {
          const sel = d === selectedDay;
          return (
            <button key={d} style={{
              aspectRatio: '1', padding: 0, borderRadius: 999,
              background: sel ? accent : 'transparent',
              border: 'none',
              color: sel ? 'rgba(20,30,60,0.92)' : 'rgba(255,255,255,0.85)',
              fontSize: 12, fontWeight: sel ? 700 : 500,
              cursor: 'pointer',
              fontVariantNumeric: 'tabular-nums',
            }}>{d}</button>
          );
        })}
      </div>
    </div>
  );
};


// ---------- repeat editor ----------
const RepeatEditor = ({ enabled, num, unit, anchor, onChangeEnabled, onChangeNum, onChangeUnit, onChangeAnchor }) => {
  const units = ['Days', 'Weeks', 'Months', 'Years'];
  const anchors = ['Completed Date', 'Schedule Date'];
  return (
    <div style={{
      borderRadius: 12,
      border: '1px solid rgba(255,255,255,0.10)',
      background: enabled ? 'rgba(216,58,255,0.08)' : 'rgba(255,255,255,0.04)',
      padding: '12px 14px',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
        <RecurringBadge size={14} color={enabled ? 'rgba(255,150,235,0.95)' : 'rgba(255,255,255,0.5)'}/>
        <span style={{ flex: 1, fontSize: 13, fontWeight: 600, color: enabled ? 'rgba(255,210,245,0.95)' : 'rgba(255,255,255,0.7)' }}>
          {enabled
            ? `Repeats every ${num} ${unit.toLowerCase()} after ${anchor.toLowerCase()}`
            : 'Does not repeat'}
        </span>
        <div onClick={() => onChangeEnabled && onChangeEnabled(!enabled)} style={{
          width: 36, height: 20, borderRadius: 999,
          background: enabled ? '#D83AFF' : 'rgba(255,255,255,0.18)',
          position: 'relative', cursor: 'pointer', transition: 'background 150ms',
          flexShrink: 0,
        }}>
          <div style={{
            position: 'absolute', top: 2, left: enabled ? 18 : 2,
            width: 16, height: 16, borderRadius: '50%', background: '#fff',
            transition: 'left 150ms',
          }}/>
        </div>
      </div>
      {enabled && (
        <div style={{ marginTop: 12, display: 'flex', flexDirection: 'column', gap: 12 }}>
          {/* every N + unit */}
          <div style={{ display: 'flex', gap: 10, alignItems: 'flex-end' }}>
            <div style={{ flex: '0 0 64px' }}>
              <FieldLabel>Every</FieldLabel>
              <input
                type="number"
                defaultValue={num}
                style={{
                  width: '100%', boxSizing: 'border-box',
                  background: 'rgba(255,255,255,0.06)',
                  border: '1px solid rgba(255,255,255,0.12)',
                  borderRadius: 8, padding: '8px 10px',
                  color: '#fff', fontSize: 14, fontWeight: 600,
                  fontFamily: 'inherit', outline: 'none',
                  fontVariantNumeric: 'tabular-nums',
                  textAlign: 'center',
                }}
              />
            </div>
            <div style={{ flex: 1 }}>
              <FieldLabel>Unit</FieldLabel>
              {/* 4-up segmented bar so they all fit */}
              <div style={{ display: 'flex', gap: 4 }}>
                {units.map(u => {
                  const sel = u === unit;
                  return (
                    <button key={u} onClick={() => onChangeUnit && onChangeUnit(u)} style={{
                      flex: 1, height: 32, padding: 0,
                      borderRadius: 6,
                      border: sel ? '1px solid rgba(255,255,255,0)' : '1px solid rgba(255,255,255,0.16)',
                      background: sel ? 'rgba(143,184,255,0.95)' : 'rgba(255,255,255,0.05)',
                      color: sel ? 'rgba(20,30,60,0.92)' : 'rgba(255,255,255,0.7)',
                      fontSize: 12, fontWeight: 600, cursor: 'pointer',
                    }}>{u}</button>
                  );
                })}
              </div>
            </div>
          </div>
          {/* anchor — 2 options, side by side */}
          <div>
            <FieldLabel>Anchor</FieldLabel>
            <div style={{ display: 'flex', gap: 6 }}>
              {anchors.map(a => {
                const sel = a === anchor;
                return (
                  <button key={a} onClick={() => onChangeAnchor && onChangeAnchor(a)} style={{
                    flex: 1, padding: '10px 12px', borderRadius: 8,
                    background: sel ? 'rgba(143,184,255,0.2)' : 'rgba(255,255,255,0.04)',
                    border: sel ? '1px solid rgba(143,184,255,0.5)' : '1px solid rgba(255,255,255,0.10)',
                    color: '#fff', fontSize: 13, fontWeight: sel ? 600 : 500, cursor: 'pointer',
                  }}>{a}</button>
                );
              })}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

// ---------- the editor ----------
const EditorFullScreen = ({ task }) => {
  const [name, setName] = React.useState(task.name);
  const [area, setArea] = React.useState(task.area);
  const [areaOptions, setAreaOptions] = React.useState(() => {
    const base = [...DEFAULT_AREAS];
    if (task.area && !base.includes(task.area)) base.push(task.area);
    return base;
  });
  const [contexts, setContexts] = React.useState(task.contexts || ['email', 'computer']);
  const [ctxOptions, setCtxOptions] = React.useState(DEFAULT_CONTEXTS);
  const [priority, setPriority] = React.useState(task.priority || 3);
  const [points, setPoints] = React.useState(task.points || 1);
  const [length, setLength] = React.useState(task.minutes || 30);
  const [notes, setNotes] = React.useState(task.notes || '');

  // dates state — start with 3 set (no urgent), so demo shows "+ Add Urgent"
  const [dates, setDates] = React.useState({
    start:  { date: 'May 1',  day: 1,  relative: '3d ago' },
    target: { date: 'May 6',  day: 6,  relative: 'in 2d' },
    due:    { date: 'May 25', day: 25, relative: 'in 21d' },
  });

  // repeat state
  const [repeatOn, setRepeatOn] = React.useState(true);
  const [repeatNum, setRepeatNum] = React.useState(3);
  const [repeatUnit, setRepeatUnit] = React.useState('Weeks');
  const [repeatAnchor, setRepeatAnchor] = React.useState('Completed Date');

  // popup state
  const [showAreaPicker, setShowAreaPicker] = React.useState(false);
  const [showCtxPicker, setShowCtxPicker] = React.useState(false);
  const [showDatesPopup, setShowDatesPopup] = React.useState(false);

  return (
    <div style={{
      width: '100%', height: '100%',
      display: 'flex', flexDirection: 'column',
      background: `linear-gradient(180deg, ${EDITOR_BG_TOP} 0%, ${EDITOR_BG} 280px)`,
      position: 'relative', overflow: 'hidden',
    }}>
      <style>{`@keyframes tm-rise { from { transform: translateY(20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }`}</style>

      {/* nav header */}
      <div style={{
        display: 'flex', alignItems: 'center', gap: 8,
        padding: '12px 14px',
        flexShrink: 0,
      }}>
        <button style={{ background: 'transparent', border: 'none', color: 'rgba(255,255,255,0.85)', cursor: 'pointer', padding: 4 }}>
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
        </button>
        <span style={{ flex: 1, textAlign: 'center', fontSize: 13, color: 'rgba(255,255,255,0.7)', fontWeight: 600, letterSpacing: 0.3 }}>Edit task</span>
        <button style={{ background: 'transparent', border: 'none', color: 'rgba(255,180,180,0.85)', cursor: 'pointer', padding: 4 }}>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
        </button>
      </div>

      {/* body */}
      <div style={{ flex: 1, overflowY: 'auto', padding: '8px 18px 110px' }}>
        {/* name */}
        <input
          defaultValue={name}
          placeholder="Task name"
          style={{
            width: '100%', boxSizing: 'border-box',
            background: 'transparent',
            border: 'none', borderBottom: '1px solid rgba(255,255,255,0.18)',
            padding: '6px 0 12px', marginBottom: 22,
            color: '#fff',
            fontSize: 24, fontWeight: 500,
            fontFamily: 'inherit', outline: 'none',
            letterSpacing: -0.2,
          }}
        />

        {/* area + contexts row — labels left, summary right; tap to open popup */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
          <div>
            <FieldLabel>Area</FieldLabel>
            <button onClick={() => setShowAreaPicker(true)} style={{
              width: '100%', display: 'flex', alignItems: 'center', gap: 10,
              padding: '11px 14px',
              background: 'rgba(255,255,255,0.05)',
              border: '1px solid rgba(255,255,255,0.10)',
              borderRadius: 10, cursor: 'pointer', textAlign: 'left',
            }}>
              <span style={{ width: 10, height: 10, borderRadius: '50%', background: AREA_COLORS[area] }}/>
              <span style={{ flex: 1, color: '#fff', fontSize: 14.5, fontWeight: 500 }}>{area}</span>
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.4)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
            </button>
          </div>

          <div>
            <FieldLabel hint={contexts.length ? `${contexts.length} selected` : 'Tap + to add'}>Contexts</FieldLabel>
            <div style={{
              display: 'flex', flexWrap: 'wrap', gap: 6,
              minHeight: 38,
              alignItems: 'center',
            }}>
              {contexts.map(c => {
                const opt = ctxOptions.find(o => o.value === c);
                return (
                  <Pill
                    key={c}
                    onRemove={() => setContexts(contexts.filter(x => x !== c))}
                  >
                    <ContextIcon name={c} size={12}/>
                    {opt?.label || c}
                  </Pill>
                );
              })}
              <AddPill onClick={() => setShowCtxPicker(true)}>Add</AddPill>
            </div>
          </div>

          {/* priority / points / length — segmented bars */}
          <div>
            <FieldLabel hint={`${priority}/5`}>Priority</FieldLabel>
            <SegmentedBar value={priority} max={5} onChange={setPriority} accent="priority"/>
          </div>
          <div>
            <FieldLabel hint={`${points} pts`}>Points</FieldLabel>
            <SegmentedBar value={points} max={8} onChange={setPoints} accent="points"/>
          </div>
          <div>
            <FieldLabel hint={fmtTime(length)}>Length</FieldLabel>
            <LengthPicker minutes={length} onChange={setLength}/>
          </div>

          {/* dates — summary chips, opens timeline popup */}
          <div>
            <FieldLabel hint="Tap to edit · all optional">Dates</FieldLabel>
            <DateSummaryRow dates={dates} onOpen={() => setShowDatesPopup(true)}/>
          </div>

          {/* repeat */}
          <div>
            <FieldLabel>Repeat</FieldLabel>
            <RepeatEditor
              enabled={repeatOn}
              num={repeatNum}
              unit={repeatUnit}
              anchor={repeatAnchor}
              onChangeEnabled={setRepeatOn}
              onChangeNum={setRepeatNum}
              onChangeUnit={setRepeatUnit}
              onChangeAnchor={setRepeatAnchor}
            />
          </div>

          {/* notes */}
          <div>
            <FieldLabel>Notes</FieldLabel>
            <InlineText value={notes} multiline placeholder="Add notes..."/>
          </div>
        </div>
      </div>

      {/* sticky save bar */}
      <div style={{
        position: 'absolute', bottom: 0, left: 0, right: 0,
        padding: '14px 18px 30px',
        background: `linear-gradient(to top, ${EDITOR_BG} 60%, ${EDITOR_BG}00)`,
        display: 'flex', gap: 10,
      }}>
        <button style={{
          flex: '0 0 auto',
          background: 'rgba(255,255,255,0.08)',
          border: '1px solid rgba(255,255,255,0.14)',
          color: 'rgba(255,255,255,0.9)',
          fontSize: 14, fontWeight: 600,
          padding: '13px 24px', borderRadius: 12,
          cursor: 'pointer',
        }}>Cancel</button>
        <button style={{
          flex: 1,
          background: '#D83AFF', border: 'none',
          color: '#fff', fontSize: 14, fontWeight: 700,
          padding: '13px 18px', borderRadius: 12,
          cursor: 'pointer',
          boxShadow: '0 4px 14px rgba(216,58,255,0.4)',
        }}>Save changes</button>
      </div>

      {/* popups */}
      {showAreaPicker && (
        <AreaPicker
          value={area}
          options={areaOptions}
          onChange={(v) => { setArea(v); setShowAreaPicker(false); }}
          onClose={() => setShowAreaPicker(false)}
          onAddNew={(name) => {
            if (!areaOptions.includes(name)) setAreaOptions([...areaOptions, name]);
            setArea(name);
            setShowAreaPicker(false);
          }}
        />
      )}
      {showCtxPicker && (
        <ContextsPicker
          selected={contexts}
          options={ctxOptions}
          onAdd={(v) => setContexts([...contexts, v])}
          onAddNew={(label) => {
            const value = label.toLowerCase().replace(/\s+/g, '_');
            if (!ctxOptions.find(o => o.value === value)) {
              setCtxOptions([...ctxOptions, { value, label }]);
            }
            setContexts([...contexts, value]);
          }}
          onClose={() => setShowCtxPicker(false)}
        />
      )}
      {showDatesPopup && (
        <DateTimelinePopup
          dates={dates}
          onChange={setDates}
          onClose={() => setShowDatesPopup(false)}
        />
      )}
    </div>
  );
};

window.TMEditors = { EditorFullScreen };
window.TMEditorWidgets = {
  FieldLabel, InlineText, SegmentedBar, LengthPicker, Pill, AddPill, AddNewInline,
  RepeatEditor, DateSummaryRow,
  AreaPicker, ContextsPicker, DateTimelinePopup,
  DEFAULT_AREAS, DEFAULT_CONTEXTS,
  EDITOR_BG, EDITOR_BG_TOP,
};
