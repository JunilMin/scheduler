package com.scheduler.backend.schedule.service;

import com.scheduler.backend.common.exception.NotFoundException;
import com.scheduler.backend.schedule.api.dto.ScheduleDtos;
import com.scheduler.backend.schedule.model.Schedule;
import com.scheduler.backend.schedule.repository.ScheduleRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

@Service
@Transactional
public class ScheduleService {

    private final ScheduleRepository scheduleRepository;

    public ScheduleService(ScheduleRepository scheduleRepository) {
        this.scheduleRepository = scheduleRepository;
    }

    public ScheduleDtos.Response create(ScheduleDtos.CreateRequest req) {
        validateTime(req.startAt(), req.endAt());
        Schedule saved = scheduleRepository.save(new Schedule(req.title(), req.memo(), req.startAt(), req.endAt()));
        return toResponse(saved);
    }

    @Transactional(readOnly = true)
    public ScheduleDtos.Response get(Long id) {
        return toResponse(findOrThrow(id));
    }

    @Transactional(readOnly = true)
    public List<ScheduleDtos.Response> list(Instant from, Instant to) {
        List<Schedule> items;
        if (from != null && to != null) {
            items = scheduleRepository.findByStartAtLessThanEqualAndEndAtGreaterThanEqual(to, from);
        } else {
            items = scheduleRepository.findAll();
        }
        return items.stream().map(this::toResponse).toList();
    }

    public ScheduleDtos.Response update(Long id, ScheduleDtos.UpdateRequest req) {
        validateTime(req.startAt(), req.endAt());
        Schedule s = findOrThrow(id);
        s.setTitle(req.title());
        s.setMemo(req.memo());
        s.setStartAt(req.startAt());
        s.setEndAt(req.endAt());
        return toResponse(s);
    }

    public void delete(Long id) {
        if (!scheduleRepository.existsById(id)) {
            throw new NotFoundException("Schedule not found: " + id);
        }
        scheduleRepository.deleteById(id);
    }

    private Schedule findOrThrow(Long id) {
        return scheduleRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Schedule not found: " + id));
    }

    private void validateTime(Instant startAt, Instant endAt) {
        if (startAt != null && endAt != null && !endAt.isAfter(startAt)) {
            throw new IllegalArgumentException("endAt must be after startAt");
        }
    }

    private ScheduleDtos.Response toResponse(Schedule s) {
        return new ScheduleDtos.Response(
                s.getId(),
                s.getTitle(),
                s.getMemo(),
                s.getStartAt(),
                s.getEndAt(),
                s.getCreatedAt(),
                s.getUpdatedAt()
        );
    }
}
