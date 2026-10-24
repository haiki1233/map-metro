/** Thanh chuyen tang — GET /api/floors, docs/RESTAPI_Spec.md muc A.1 */
export default function FloorSwitcher({
  floors,
  currentFloorId,
  onChange,
  criteria,
  onCriteriaChange,
  disabled = false,
}) {
  return (
    <div className="floor-controls">
      <div className="floor-switcher">
        {floors.map((floor) => (
          <button
            key={floor.id}
            className={floor.id === currentFloorId ? 'active' : ''}
            onClick={() => onChange(floor.id)}
          >
            {floor.name}
          </button>
        ))}
      </div>
      <button
        type="button"
        className={`wheelchair-mode-button ${criteria === 'accessible' ? 'active' : ''}`}
        aria-label="Chế độ xe lăn"
        aria-pressed={criteria === 'accessible'}
        title="Chế độ xe lăn"
        disabled={disabled}
        onClick={() => onCriteriaChange(criteria === 'accessible' ? 'distance' : 'accessible')}
      >
        ♿
      </button>
    </div>
  );
}
