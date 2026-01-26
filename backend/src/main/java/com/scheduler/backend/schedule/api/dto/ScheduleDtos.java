package com.scheduler.backend.schedule.api.dto;

import java.time.Instant;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public class ScheduleDtos {

    public record CreateRequest(
            @NotBlank @Size(max = 200) String title,
            String memo,
            @NotNull Instant startAt,
            @NotNull Instant endAt
    ) {}

    public record UpdateRequest(
            @NotBlank @Size(max = 200) String title,
            String memo,
            @NotNull Instant startAt,
            @NotNull Instant endAt
    ) {}

    public record Response(
            Long id,
            String title,
            String memo,
            Instant startAt,
            Instant endAt,
            Instant createdAt,
            Instant updatedAt
    ) {}
}
