.PHONY: validate compose-up compose-down

validate:
	python -m json.tool schemas/vital_event.avsc >/dev/null
	python -m json.tool schemas/clinical_event.avsc >/dev/null
	python -m compileall -q ingestion processing rag tests
	docker compose config >/dev/null

compose-up:
	docker compose up -d

compose-down:
	docker compose down