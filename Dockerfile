FROM python:3.10-alpine
ENV PYTHONDONTWRITEBYTECODE=1
COPY app/requirements.txt requirements.txt
RUN pip install --require-hashes -r requirements.txt --no-deps --no-cache-dir
COPY app app
ENV GOOGLE_APPLICATION_CREDENTIALS app/service_account.json
ENTRYPOINT ["./app/run-local.sh", "--quiet"]
CMD ["--google-ads-config", "/google-ads.yaml", "--config", "/dactionboard.yaml"]
