package com.metro.indoornav.repository;

import com.metro.indoornav.entity.Room;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface RoomRepository extends JpaRepository<Room, Integer> {

    List<Room> findByFloorId(Integer floorId);

    /**
     * B.1 GET /api/rooms/search
     * Kết hợp to_tsvector cho từ khóa text và ILIKE cho mã code/chuỗi con.
     *
     * Dung immutable_unaccent() chu khong phai unaccent() tran: unaccent() duoc danh dau STABLE
     * nen KHONG the dung trong bieu thuc index, khien moi truy van phai quet toan bang.
     * Ham bao immutable_unaccent() (database/schema_fix_v2.sql) la ban IMMUTABLE cua no, va hai
     * chi muc idx_room_name_unaccent / idx_room_name_trgm duoc dung dung theo bieu thuc nay.
     */
    @Query(value = """
            SELECT * FROM room
            WHERE (
                :q = ''
                OR
                to_tsvector('simple', immutable_unaccent(name)) @@ plainto_tsquery('simple', immutable_unaccent(:q))
                OR immutable_unaccent(name) ILIKE immutable_unaccent('%' || :q || '%')
            )
              AND (:category IS NULL OR category = :category)
              AND (:floorId IS NULL OR floor_id = :floorId)
            ORDER BY
                -- Ten bat dau bang tu khoa len truoc, roi moi den khop giua chuoi
                CASE WHEN :q <> '' AND immutable_unaccent(name) ILIKE immutable_unaccent(:q) || '%' THEN 0 ELSE 1 END,
                length(name),
                name
            LIMIT 50
            """, nativeQuery = true)
    List<Room> search(@Param("q") String q,
                       @Param("category") String category,
                       @Param("floorId") Integer floorId);
}