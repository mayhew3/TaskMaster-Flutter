// wide-editor.jsx — docked right-pane editor for the wide layout.
// Reuses every widget from the phone full-screen editor; the only thing
// that differs is the chrome: no back-arrow page-push, no full-screen save
// bar wrapping. Same fields and grouping (Task name, Area, Contexts,
// Priority /5, Points, Length, Dates, Repeat, Notes).

const { AREA_COLORS, ContextIcon, fmtTime } = window.TMHelpers;
const {
  FieldLabel, InlineText, SegmentedBar, LengthPicker, Pill, AddPill,
  RepeatEditor, DateSummaryRow,
  AreaPicker, ContextsPicker, DateTimelinePopup,
  DEFAULT_AREAS, DEFAULT_CONTEXTS,
} = window.TMEditorWidgets;
const { Icon } = window.TMChrome;

// Small toolbar action button (matches the editor's visual language).
const EditorIconBtn = ({ children, onClick, danger, title }) => (
  <button onClick={onClick} title={title} style={{
    width: 32, height: 32, borderRadius: 9,
    background: 'rgba(255,255,255,0.05)',
    border: '1px solid rgba(255,255,255,0.10)',
    color: danger ? 'rgba(255,180,180,0.85)' : 'rgba(255,255,255,0.78)',
    display: 'flex', alignItems: 'center', justifyContent: 'center',
    cursor: 'pointer',
  }}>{children}</button>
);

// ============================================================
// EditorDocked — the docked right-pane variant of the editor
// ============================================================
const EditorDocked = ({ task, onClose, width = 400, compact = false }) => {
  const [name, setName] = React.useState(task.name);
  const [area, setArea] = React.useState(task.area);
  const [areaOptions, setAreaOptions] = React.useState(() => {
    const base = [...DEFAULT_AREAS];
    if (task.area && !base.includes(task.area)) base.push(task.area);
    return base;
  });
  const [contexts, setContexts] = React.useState(task.contexts || []);
  const [ctxOptions, setCtxOptions] = React.useState(DEFAULT_CONTEXTS);
  const [priority, setPriority] = React.useState(task.priority || 3);
  const [points, setPoints] = React.useState(task.points || 1);
  const [length, setLength] = React.useState(task.minutes || 30);
  const [notes, setNotes] = React.useState(task.notes || '');

  // Seed dates from the sample task's dates blob (best-effort —
  // the sample has {date, relative} but the popup wants {date, day, relative}).
  const seedDates = React.useMemo(() => {
    const out = {};
    const src = task.dates || {};
    const guessDay = (s) => {
      const m = /(\d{1,2})/.exec(s || '');
      return m ? parseInt(m[1]) : 1;
    };
    for (const k of ['start','target','urgent','due']) {
      if (src[k]) out[k] = { date: src[k].date, day: guessDay(src[k].date), relative: src[k].relative };
    }
    return out;
  }, [task.id]);

  const [dates, setDates] = React.useState(seedDates);

  // repeat state
  const [repeatOn, setRepeatOn] = React.useState(!!task.recurring);
  const [repeatNum, setRepeatNum] = React.useState(task.recurring ? 3 : 1);
  const [repeatUnit, setRepeatUnit] = React.useState('Weeks');
  const [repeatAnchor, setRepeatAnchor] = React.useState('Completed Date');

  // popups
  const [showAreaPicker, setShowAreaPicker] = React.useState(false);
  const [showCtxPicker, setShowCtxPicker] = React.useState(false);
  const [showDatesPopup, setShowDatesPopup] = React.useState(false);

  const dotColor = AREA_COLORS[area] || '#9F86FF';

  return (
    <div style={{
      width,
      flexShrink: 0,
      background: 'var(--card)',
      borderLeft: '1px solid rgba(0,0,0,0.18)',
      display: 'flex', flexDirection: 'column',
      position: 'relative', overflow: 'hidden',
      color: '#fff',
    }}>
      <style>{`@keyframes tm-rise { from { transform: translateY(20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }`}</style>

      {/* header — different from full-screen: no back chevron, has close */}
      <div style={{
        padding: '14px 16px 14px 18px',
        background: 'linear-gradient(180deg, rgba(255,255,255,0.05), rgba(255,255,255,0) 100%)',
        borderBottom: '1px solid rgba(255,255,255,0.06)',
        display: 'flex', alignItems: 'center', gap: 10,
        flexShrink: 0,
      }}>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{
            fontSize: 10.5, fontWeight: 700, letterSpacing: 0.7,
            textTransform: 'uppercase', color: 'rgba(255,255,255,0.55)',
          }}>Task details</div>
          <div style={{
            fontSize: 13, color: 'rgba(255,255,255,0.78)', marginTop: 1,
            display: 'flex', alignItems: 'center', gap: 6,
          }}>
            <span style={{ width: 8, height: 8, borderRadius: '50%', background: dotColor }}/>
            <span style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{area}</span>
            {task.project && (
              <>
                <span style={{ opacity: 0.5 }}>·</span>
                <span style={{ color: 'rgba(200,255,220,0.85)', fontWeight: 600 }}>{task.project} {task.projectStep}/{task.projectTotal}</span>
              </>
            )}
          </div>
        </div>
        <EditorIconBtn title="Delete" danger>
          <Icon name="trash" size={14}/>
        </EditorIconBtn>
        {onClose && (
          <EditorIconBtn onClick={onClose} title="Close">
            <Icon name="x" size={14}/>
          </EditorIconBtn>
        )}
      </div>

      {/* body */}
      <div style={{ flex: 1, overflowY: 'auto', padding: '14px 18px 110px' }}>
        {/* name */}
        <input
          defaultValue={name}
          placeholder="Task name"
          style={{
            width: '100%', boxSizing: 'border-box',
            background: 'transparent',
            border: 'none', borderBottom: '1px solid rgba(255,255,255,0.18)',
            padding: '4px 0 11px', marginBottom: 20,
            color: '#fff',
            fontSize: 21, fontWeight: 500,
            fontFamily: 'inherit', outline: 'none',
            letterSpacing: -0.2, lineHeight: 1.25,
          }}
        />

        <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
          {/* Area + Contexts (side-by-side on the wider pane) */}
          <div>
            <FieldLabel>Area</FieldLabel>
            <button onClick={() => setShowAreaPicker(true)} style={{
              width: '100%', display: 'flex', alignItems: 'center', gap: 10,
              padding: '11px 14px',
              background: 'rgba(255,255,255,0.05)',
              border: '1px solid rgba(255,255,255,0.10)',
              borderRadius: 10, cursor: 'pointer', textAlign: 'left',
            }}>
              <span style={{ width: 10, height: 10, borderRadius: '50%', background: dotColor }}/>
              <span style={{ flex: 1, color: '#fff', fontSize: 14, fontWeight: 500 }}>{area}</span>
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.4)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
            </button>
          </div>

          <div>
            <FieldLabel hint={contexts.length ? `${contexts.length} selected` : 'Tap + to add'}>Contexts</FieldLabel>
            <div style={{
              display: 'flex', flexWrap: 'wrap', gap: 5,
              minHeight: 36, alignItems: 'center',
            }}>
              {contexts.map(c => {
                const opt = ctxOptions.find(o => o.value === c);
                return (
                  <Pill key={c} onRemove={() => setContexts(contexts.filter(x => x !== c))}>
                    <ContextIcon name={c} size={12}/>
                    {opt?.label || c}
                  </Pill>
                );
              })}
              <AddPill onClick={() => setShowCtxPicker(true)}>Add</AddPill>
            </div>
          </div>

          {/* Priority + Points + Length */}
          <div>
            <FieldLabel hint={`${priority}/5`}>Priority</FieldLabel>
            <SegmentedBar value={priority} max={5} onChange={setPriority} accent="priority"/>
          </div>
          <div>
            <FieldLabel hint={`${points} pts`}>Points</FieldLabel>
            <SegmentedBar value={points} max={8} onChange={setPoints} accent="points"/>
          </div>
          <div>
            <FieldLabel hint={fmtTime(length)}>Length / effort</FieldLabel>
            <LengthPicker minutes={length} onChange={setLength}/>
          </div>

          {/* Dates */}
          <div>
            <FieldLabel hint="Start · Target · Urgent · Due">Dates</FieldLabel>
            <DateSummaryRow dates={dates} onOpen={() => setShowDatesPopup(true)}/>
          </div>

          {/* Repeat */}
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

          {/* Notes */}
          <div>
            <FieldLabel>Notes</FieldLabel>
            <InlineText value={notes} multiline placeholder="Add notes..."/>
          </div>
        </div>
      </div>

      {/* sticky bottom save bar (same shape as phone, smaller padding) */}
      <div style={{
        position: 'absolute', bottom: 0, left: 0, right: 0,
        padding: '14px 18px 18px',
        background: `linear-gradient(to top, var(--card) 65%, transparent)`,
        display: 'flex', gap: 10,
      }}>
        <button style={{
          flex: '0 0 auto',
          background: 'rgba(255,255,255,0.08)',
          border: '1px solid rgba(255,255,255,0.14)',
          color: 'rgba(255,255,255,0.9)',
          fontSize: 13, fontWeight: 600,
          padding: '11px 18px', borderRadius: 12,
          cursor: 'pointer',
        }}>Cancel</button>
        <button style={{
          flex: 1,
          background: '#D83AFF', border: 'none',
          color: '#fff', fontSize: 13.5, fontWeight: 700,
          padding: '11px 18px', borderRadius: 12,
          cursor: 'pointer',
          boxShadow: '0 4px 14px rgba(216,58,255,0.40)',
        }}>Save changes</button>
      </div>

      {/* popups (positioned inside this pane via PopupOverlay's inset:0) */}
      {showAreaPicker && (
        <AreaPicker
          value={area}
          options={areaOptions}
          onChange={(v) => { setArea(v); setShowAreaPicker(false); }}
          onClose={() => setShowAreaPicker(false)}
          onAddNew={(n) => {
            if (!areaOptions.includes(n)) setAreaOptions([...areaOptions, n]);
            setArea(n);
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

window.TMWideEditor = { EditorDocked };
