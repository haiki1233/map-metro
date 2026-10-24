import { useMemo } from 'react';
import {
  enrichSteps,
  maneuverIcon,
  maneuverLabel,
  stepDistanceLabel,
  formatDistance,
  formatDuration,
  remainingAfter,
} from '../utils/routeGuidance.js';

const CRITERIA_LABEL = {
  distance: 'Ngắn nhất',
  time: 'Nhanh nhất',
  least_stairs: 'Ít cầu thang',
};

const TRANSFER_LABEL = {
  elevator: 'Thang máy',
  escalator: 'Thang cuốn',
  stair: 'Cầu thang bộ',
};

/**
 * Hiển thị kết quả POST /api/route — docs/RESTAPI_Spec.md mục C.1 (FR-08..FR-11).
 *
 * 4 chế độ:
 *  1. Chưa có tuyến  → gợi ý chọn 2 đầu + bộ chọn tiêu chí
 *  2. Tổng quan      → tổng quãng đường/thời gian + danh sách bước + nút "Bắt đầu"
 *  3. Đang dẫn đường → thẻ chỉ dẫn lớn theo bước hiện tại + Trước/Tiếp
 *  4. Đã đến         → khi vượt quá bước cuối
 */
export default function RoutePanel({
  route,
  error,
  isLoading = false,
  criteria,
  onCriteriaChange,
  floors = [],
  startLabel,
  endLabel,
  activeStepIndex,
  onActiveStepChange,
  onStartNavigation,
  onStopNavigation,
  onFitRoute,
}) {
  const steps = useMemo(() => enrichSteps(route), [route]);

  const isNavigating = activeStepIndex >= 0;
  const isArrived = isNavigating && activeStepIndex >= steps.length;
  const currentStep = isNavigating && !isArrived ? steps[activeStepIndex] : null;
  const remaining = isNavigating ? remainingAfter(steps, activeStepIndex) : null;

  const floorName = (floorId) =>
    floors.find((f) => f.id === floorId)?.name || `Tầng ${floorId}`;

  const criteriaSwitch = (
    <div className="criteria-switch">
      {Object.entries(CRITERIA_LABEL).map(([value, label]) => (
        <button
          key={value}
          className={value === criteria ? 'active' : ''}
          onClick={() => onCriteriaChange(value)}
          disabled={isNavigating}
        >
          {label}
        </button>
      ))}
    </div>
  );

  /** Danh sách bước — bấm 1 dòng để nhảy tới bước đó. Dùng chung cho cả 2 chế độ. */
  const stepsList = () => (
    <ol className="route-steps">
      {steps.map((step, i) => (
        <li
          key={step.order}
          className={i === activeStepIndex ? 'active' : i < activeStepIndex ? 'completed' : ''}
        >
          <button
            type="button"
            className="route-step-button"
            aria-current={i === activeStepIndex ? 'step' : undefined}
            onClick={() => onActiveStepChange(i)}
          >
            <span className="step-icon">{maneuverIcon(step.maneuver)}</span>
            <span className="step-body">
              <span className="step-text">{step.instruction}</span>
              <span className="step-meta">
                {floorName(step.floorId)} · {stepDistanceLabel(step)}
              </span>
            </span>
          </button>
        </li>
      ))}
    </ol>
  );

  // ===== Trạng thái lỗi =====
  if (error) {
    return (
      <div className="route-panel">
        <div className="route-error">{error}</div>
        {criteriaSwitch}
      </div>
    );
  }

  if (isLoading) {
    return (
      <div className="route-panel">
        <p className="muted route-hint">Đang tính tuyến đường...</p>
        {criteriaSwitch}
      </div>
    );
  }

  // ===== 1. Chưa có tuyến =====
  if (!route || steps.length === 0) {
    return (
      <div className="route-panel">
        <p className="muted route-hint">
          {startLabel
            ? 'Chọn điểm đến để xem chỉ dẫn'
            : 'Chọn điểm đi và điểm đến ở trên, hoặc bấm trực tiếp lên bản đồ'}
        </p>
        {criteriaSwitch}
      </div>
    );
  }

  // ===== 4. Đã đến =====
  if (isArrived) {
    return (
      <div className="route-panel">
        <div className="arrive-card">
          <div className="arrive-icon">📍</div>
          <strong>Bạn đã đến {endLabel || 'điểm đến'}</strong>
          <span className="muted">{formatDistance(route.totalDistance)}</span>
        </div>
        <button className="primary-btn" onClick={onStopNavigation}>
          Kết thúc
        </button>
      </div>
    );
  }

  // ===== 3. Đang dẫn đường =====
  if (currentStep) {
    const nextStep = steps[activeStepIndex + 1];
    const isLast = activeStepIndex === steps.length - 1;

    return (
      <div className="route-panel">
        <div className="guidance-card">
          <div className="guidance-icon">{maneuverIcon(currentStep.maneuver)}</div>
          <div className="guidance-text">
            <div className="guidance-title">{maneuverLabel(currentStep.maneuver)}</div>
            <div className="guidance-sub">{currentStep.instruction}</div>
          </div>
          <span className="guidance-floor">{floorName(currentStep.floorId)}</span>
        </div>

        <div className="nav-progress">
          <strong>
            Còn {formatDistance(remaining.distance)} · Khoảng {formatDuration(remaining.duration)}
          </strong>
          <span className="muted">
            Bước {activeStepIndex + 1}/{steps.length}
          </span>
        </div>

        {nextStep && (
          <div className="next-step">
            <span className="step-icon small">{maneuverIcon(nextStep.maneuver)}</span>
            <span className="muted">Bước sau: {maneuverLabel(nextStep.maneuver)}</span>
          </div>
        )}

        <div className="nav-buttons">
          <button
            className="secondary-btn"
            onClick={() => onActiveStepChange(activeStepIndex - 1)}
            disabled={activeStepIndex === 0}
          >
            ‹ Trước
          </button>
          <button className="primary-btn" onClick={() => onActiveStepChange(activeStepIndex + 1)}>
            {isLast ? 'Đến nơi' : 'Tiếp ›'}
          </button>
        </div>

        <div className="nav-buttons">
          <button className="link-btn" onClick={onFitRoute}>
            Xem toàn tuyến
          </button>
          <button className="link-btn danger" onClick={onStopNavigation}>
            Kết thúc
          </button>
        </div>

        {stepsList()}
      </div>
    );
  }

  // ===== 2. Tổng quan =====
  return (
    <div className="route-panel">
      <div className="route-summary">
        <div className="summary-main">
          <strong>{formatDistance(route.totalDistance)}</strong>
          <span className="muted"> · khoảng {formatDuration(route.totalTimeEstimate)}</span>
        </div>
        <span className="muted">{steps.length} bước</span>
      </div>

      {criteriaSwitch}

      {route.transferPoints?.length > 0 && (
        <div className="transfer-points">
          {route.transferPoints.map((tp) => (
            <div key={`${tp.nodeId}-${tp.transferType}`} className="transfer-point">
              {TRANSFER_LABEL[tp.transferType] || tp.transferType}: {floorName(tp.fromFloorId)} →{' '}
              {floorName(tp.toFloorId)} · ~{formatDuration(tp.avgTime)}
            </div>
          ))}
        </div>
      )}

      {stepsList()}

      <button className="primary-btn" onClick={onStartNavigation}>
        Bắt đầu
      </button>
    </div>
  );
}