import { apiClient } from './client.js';
import {
  mockFloors,
  mockFloor1Map,
  mockFloor2Map,
  mockSearchResults,
  mockSearchEmpty,
  mockNearestNode,
  mockRouteResponse,
  mockRouteResponseByTime,
  mockRouteError,
} from '../mock/mockData.js';

const mockTransform = {
  floorId: 1,
  originLat: 10.772,
  originLng: 106.698,
  scaleX: 1,
  scaleY: 1,
  rotationDeg: 0,
};
const emptyFeatureCollection = { type: 'FeatureCollection', features: [] };

/**
 * VITE_USE_MOCK=true -> dung frontend/src/mock/mockData.js thay vi goi Backend that.
 * Cho phep code FE song song voi BE (xem docs/ROADMAP.md giai doan 1) — cau truc du lieu tra
 * ve GIONG HET response that (mockData.js da duoc verify khop schema.sql + seed_data.sql),
 * nen khi tat mock chi can doi bien env, khong phai sua component nao ca.
 */
const USE_MOCK = import.meta.env.VITE_USE_MOCK === 'true';

const delay = (ms = 200) => new Promise((resolve) => setTimeout(resolve, ms));

// ===== A. Ban do =====

export async function getFloors() {
  if (USE_MOCK) {
    await delay();
    return mockFloors;
  }
  const { data } = await apiClient.get('/floors');
  return data;
}

export async function getFloorMap(floorId) {
  if (USE_MOCK) {
    await delay();
    if (Number(floorId) === 1) return mockFloor1Map;
    if (Number(floorId) === 2) return mockFloor2Map;
    throw new Error('NOT_FOUND');
  }
  const { data } = await apiClient.get(`/floors/${floorId}/map`);
  return data;
}

/**
 * A.3 Tam ban do cua 1 tang (floor_transform) — dung lam `center` cho MapContainer.
 * Tra ve ca scale/rotation de sau nay doi chieu toa do local <-> WGS84 neu can.
 */
export async function getFloorTransform(floorId) {
  if (USE_MOCK) {
    await delay();
    return { ...mockTransform, floorId: Number(floorId) };
  }
  const { data } = await apiClient.get(`/map/floors/${floorId}/transform`);
  return data;
}

/**
 * A.4 Hinh hoc nen CAD cua 1 tang, da la GeoJSON FeatureCollection dung san tu PostgreSQL.
 * Tra thang `data` cho <GeoJSON data={...}> (axios tu parse vi response la application/json).
 */
export async function getFloorFeatures(floorId) {
  if (USE_MOCK) {
    await delay();
    return emptyFeatureCollection;
  }
  const { data } = await apiClient.get(`/map/features/${floorId}`);
  return data;
}

// ===== B. Tim kiem & dinh vi diem =====

export async function searchRooms(q, category = null, floorId = null) {
  if (USE_MOCK) {
    await delay();
    // Khi dùng mock, tạm thời nới lỏng điều kiện hoặc bạn nên tắt hẳn VITE_USE_MOCK=false
    return q?.toLowerCase().includes('san ga') || q?.toLowerCase().includes('sân ga')
      ? mockSearchResults
      : mockSearchEmpty;
  }
  const { data } = await apiClient.get('/rooms/search', {
    params: { q, category, floorId },
  });
  return data;
}

export async function findNearestNode(lat, lng, floorId, maxDistance = 15) {
  if (USE_MOCK) {
    await delay();
    return mockNearestNode;
  }
  const { data } = await apiClient.get('/nodes/nearest', { params: { lat, lng, floorId, maxDistance } });
  return data;
}

// ===== C. Dinh tuyen =====

export async function findRoute(startNodeId, endNodeId, criteria = 'distance') {
  if (USE_MOCK) {
    await delay(400);
    if (startNodeId === 2) throw Object.assign(new Error('ROUTE_NOT_FOUND'), { response: { data: mockRouteError } });
    if (criteria === 'time') return mockRouteResponseByTime;
    if (criteria === 'accessible') return mockRouteResponse;
    return mockRouteResponse;
  }
  const { data } = await apiClient.post('/route', { startNodeId, endNodeId, criteria });
  return data;
}
