FROM python:3.12 as builder

WORKDIR /app

RUN python -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

COPY ./requirements.txt .

RUN --mount=type=cache,target=~/.cache/pip pip install -r requirements.txt

FROM python:3.12-slim as worker
WORKDIR /app

RUN addgroup --system python && \
    adduser --system --disabled-password  --ingroup python python && chown python:python /app
USER python

COPY --chown=python:python --from=builder /app/venv ./venv
COPY --chown=python:python . .

ENV PATH="/app/venv/bin:$PATH"

CMD ["python", "main.py"]