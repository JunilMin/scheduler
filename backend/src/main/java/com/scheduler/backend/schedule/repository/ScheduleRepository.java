package com.scheduler.backend.schedule.repository;

import com.scheduler.backend.schedule.model.Schedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;

@Repository
public interface ScheduleRepository extends JpaRepository<Schedule, Long> {

    // 기간 필터(선택): from~to 사이에 겹치는 일정 (start<=to && end>=from)
    List<Schedule> findByStartAtLessThanEqualAndEndAtGreaterThanEqual(Instant to, Instant from);
}
