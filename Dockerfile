FROM python:3.10-alpine3.17
LABEL maintainer="cemsavas.com"

ENV PYTHONUNBUFFERED 1

# requirements'i tmp icine kopyalar
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false
# ilk satir venv olusturur
# 2. pip upgrade eder
# 3.requirements yukler
# 4. extra dependencies olmamasi icin tmp silinir
# 5. docker image icerisinde bir user olusturur. bu bir root userdır ve image icerisinde full yetkiye sahiptir
# bu yuzden olasi ataklara onlem almak icin bu userın yetkisi kisitlanir
# son satir ise user adidir degistirilebilir
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \ 
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# path linux tarafından otomatik olarak olusturulan ortam degiskenidir
ENV PATH="/py/bin:$PATH"

USER django-user