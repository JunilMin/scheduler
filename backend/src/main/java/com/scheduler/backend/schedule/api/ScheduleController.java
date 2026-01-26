package com.scheduler.backend.schedule.api;

import java.time.Instant;
import java.util.List;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.scheduler.backend.schedule.api.dto.ScheduleDtos;
import com.scheduler.backend.schedule.service.ScheduleService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/schedules")
public class ScheduleController {

    private final ScheduleService scheduleService;

    public ScheduleController(ScheduleService scheduleService) {
        this.scheduleService = scheduleService;
    }

    @PostMapping
    public ScheduleDtos.Response create(@Valid @RequestBody ScheduleDtos.CreateRequest req) {
        return scheduleService.create(req);
    }

    @GetMapping("/{id}")
    public ScheduleDtos.Response get(@PathVariable Long id) {
        return scheduleService.get(id);
    }

    // 예: /api/schedules?from=2026-01-01T00:00:00Z&to=2026-01-31T23:59:59Z
    @GetMapping
    public List<ScheduleDtos.Response> list(
        @RequestParam(name = "from", required = false)
        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant from,

        @RequestParam(name = "to", required = false)
        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant to
        ) {
        return scheduleService.list(from, to);
    }  


    @PutMapping("/{id}")
    public ScheduleDtos.Response update(@PathVariable Long id, @Valid @RequestBody ScheduleDtos.UpdateRequest req) {
        return scheduleService.update(id, req);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        scheduleService.delete(id);
    }
}
