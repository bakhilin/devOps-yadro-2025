#
# NOTE: THIS DOCKERFILE WAS CREATED AT THE YADRO DEVOPS EDUCATIONAL COURSES.
#

FROM python:3.12-alpine@sha256:28b8a72c4e0704dd2048b79830e692e94ac2d43d30c914d54def6abf74448a4e 

WORKDIR /currency/
COPY pyproject.toml /currency/

ARG POETRY_VERSION=1.5.0
RUN pip install --no-cache-dir \ 
    poetry==${POETRY_VERSION} \
    && poetry config virtualenvs.create false \
    && poetry install --no-root \
    && pip uninstall -y poetry

COPY . /currency/ 

ARG HOST=localhost
ARG PORT=8000
ARG CURRENCY_VERSION=0.1.0

ENV HOST=${HOST} \
    PORT=${PORT} \
    VERSION=${CURRENCY_VERSION}    

LABEL version=${VERSION} \
      description="Currency REST API client-server application" \
      author="n.bakhilin"

EXPOSE 8000/tcp

ENTRYPOINT [ "python" ]
CMD [ "main.py" ]
