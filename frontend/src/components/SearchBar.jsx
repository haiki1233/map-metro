import { useState, useEffect, useRef } from 'react';
import { searchRooms } from '../api/indoorNavApi.js';

/**
 * Hai ô Điểm đi / Điểm đến dùng CHUNG một state `query` + một debounce, điều khiển bởi
 * `activeRole` = ô đang focus. Không nhân đôi logic tìm kiếm: chỉ ô đang focus hiện kết quả.
 *
 * Props:
 *  - floors           : danh sách tầng từ GET /api/floors — để tra tên tầng, vì
 *                       RoomSearchResult chỉ có `floorId`, KHÔNG có `floorName`.
 *  - criteria         : 'distance' | 'time' | 'least_stairs'
 *  - startLabel/endLabel : nhãn đang hiển thị ở mỗi ô (do App giữ)
 *  - onSelectStart/onSelectEnd(result)
 *  - onClear(role)    : xoá 1 đầu
 *  - onSwap()         : hoán đổi điểm đi <-> điểm đến
 */
export default function SearchBar({
  floors = [],
  criteria,
  startLabel,
  endLabel,
  onSelectStart,
  onSelectEnd,
  onClear,
  onSwap,
}) {
  const [query, setQuery] = useState('');
  const [activeRole, setActiveRole] = useState('end'); // ô đang focus — mặc định điểm đến
  const [results, setResults] = useState([]);
  const [quickCategory, setQuickCategory] = useState(null);
  const [loading, setLoading] = useState(false);
  const [hasSearched, setHasSearched] = useState(false);
  const [searchError, setSearchError] = useState(null);
  const debounceRef = useRef(null);

  // Chế độ xe lăn chỉ ưu tiên các lối tiếp cận được.
  const isAccessibleMode = criteria === 'accessible';

  const quickSuggestions = [
    { label: 'Thang máy', icon: '🛗', category: 'elevator' },
    { label: 'Cầu thang', icon: '🪜', category: 'stair' },
    { label: 'Thang cuốn', icon: '↗️', category: 'escalator' },
    { label: 'Khu vực', icon: '📍', category: 'room' },
    { label: 'Cổng', icon: '🚪', category: 'gate' },
    { label: 'Bãi xe', icon: '🅿️', category: 'parking' },
    { label: 'Nhà vệ sinh', icon: '🚻', category: 'toilet' }
  ];

  // Debounce dùng chung cho cả hai ô — chỉ phụ thuộc `query`, không phụ thuộc ô nào.
  useEffect(() => {
    if (debounceRef.current) clearTimeout(debounceRef.current);

    const trimmed = query.trim();
    if (trimmed.length < 2 && !quickCategory) {
      setResults([]);
      setHasSearched(false);
      setLoading(false);
      setSearchError(null);
      return;
    }

    let isCurrentSearch = true;
    debounceRef.current = setTimeout(async () => {
      setLoading(true);
      setHasSearched(true);
      setSearchError(null);
      try {
        const data = await searchRooms(trimmed, quickCategory);
        if (isCurrentSearch) setResults(data || []);
      } catch (error) {
        console.error('Lỗi tìm kiếm:', error);
        if (isCurrentSearch) {
          setResults([]);
          setSearchError(error.response?.data?.message || 'Không thể kết nối dịch vụ tìm kiếm');
        }
      } finally {
        if (isCurrentSearch) setLoading(false);
      }
    }, 400);

    return () => {
      isCurrentSearch = false;
      clearTimeout(debounceRef.current);
    };
  }, [query, quickCategory]);

  function focusField(role) {
    setActiveRole(role);
  }

  function handleSelect(result) {
    if (activeRole === 'start') onSelectStart(result);
    else onSelectEnd(result);
    setQuery('');
    setQuickCategory(null);
    setResults([]);
    setHasSearched(false);
    setSearchError(null);
  }

  function handleQuickClick(category) {
    setQuery('');
    setQuickCategory(category);
    setResults([]);
    setHasSearched(false);
    setSearchError(null);
  }

  function clearField(role, e) {
    e.stopPropagation();
    setQuery('');
    setQuickCategory(null);
    setResults([]);
    setHasSearched(false);
    setSearchError(null);
    onClear?.(role);
  }

  const floorNameOf = (floorId) => floors.find((f) => f.id === floorId)?.name || `Tầng ${floorId}`;

  const showResults = !loading && !searchError && results.length > 0;
  const showEmpty = !loading && !searchError && hasSearched && results.length === 0;
  const showQuick = query.trim().length < 2 && !quickCategory;
  const quickCategoryLabel = quickSuggestions.find((item) => item.category === quickCategory)?.label;

  return (
    <div className="search-bar">
      <div className="route-fields">
        {/* --- ĐIỂM ĐI --- */}
        <div className={`route-field ${activeRole === 'start' ? 'focused' : ''}`}>
          <span className="route-field-dot start" />
          <input
            type="text"
            value={activeRole === 'start' ? query : ''}
            onChange={(e) => {
              setQuickCategory(null);
              setQuery(e.target.value);
            }}
            onFocus={() => focusField('start')}
            placeholder={startLabel || 'Chọn điểm đi'}
          />
          {startLabel && activeRole !== 'start' && (
            <button type="button" className="field-clear" onClick={(e) => clearField('start', e)} title="Xoá điểm đi">
              ✕
            </button>
          )}
        </div>

        {/* --- NÚT HOÁN ĐỔI --- */}
        <button type="button" className="swap-btn" onClick={onSwap} title="Hoán đổi điểm đi và điểm đến">
          ⇅
        </button>

        {/* --- ĐIỂM ĐẾN --- */}
        <div className={`route-field ${activeRole === 'end' ? 'focused' : ''}`}>
          <span className="route-field-dot end" />
          <input
            type="text"
            value={activeRole === 'end' ? query : ''}
            onChange={(e) => {
              setQuickCategory(null);
              setQuery(e.target.value);
            }}
            onFocus={() => focusField('end')}
            placeholder={endLabel || 'Chọn điểm đến'}
          />
          {endLabel && activeRole !== 'end' && (
            <button type="button" className="field-clear" onClick={(e) => clearField('end', e)} title="Xoá điểm đến">
              ✕
            </button>
          )}
        </div>
      </div>

      {/* GỢI Ý NHANH — chỉ khi ô đang focus còn rỗng */}
      {showQuick && (
        <div className="quick-suggestions">
          {quickSuggestions.map((item) => (
            <button key={item.category} type="button" onClick={() => handleQuickClick(item.category)}>
              {item.icon} {item.label}
            </button>
          ))}
        </div>
      )}

      {loading && <p className="muted search-hint">Đang tìm kiếm...</p>}
      {searchError && <p className="search-error">{searchError}</p>}

      {showResults && (
        <ul className="search-results">
          {results.map((r) => {
            // Chế độ ưu tiên không vật cản: đánh dấu kết quả là thang máy
            const isAccessibleNode = isAccessibleMode && r.category === 'elevator';
            return (
              <li key={`${r.resultType || 'room'}-${r.id}`} onClick={() => handleSelect(r)}>
                <div className="result-row">
                  <strong style={{ color: isAccessibleNode ? '#10b981' : '#334155' }}>
                    {isAccessibleNode ? '♿ ' : ''}
                    {r.name}
                  </strong>
                  <span className="result-floor">{floorNameOf(r.floorId)}</span>
                </div>
              </li>
            );
          })}
        </ul>
      )}

      {showEmpty && (
        <div className="search-empty">
          <p className="muted">
            {quickCategoryLabel
              ? `Không tìm thấy ${quickCategoryLabel.toLowerCase()} nào`
              : `Không tìm thấy kết quả nào cho "${query}"`}
          </p>
          <p className="search-hint">Thử các gợi ý phù hợp với dữ liệu tầng hiện có.</p>
        </div>
      )}
    </div>
  );
}