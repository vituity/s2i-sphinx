FROM centos/s2i-core-centos7

EXPOSE 8080

LABEL io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,sphinx"

RUN yum install -y centos-release-scl
RUN yum install -y rh-python36 rh-nginx112
RUN yum install -y make
COPY contrib/ ${APP_ROOT}

RUN sed -i -f ${APP_ROOT}/nginxconf.sed /etc/opt/rh/rh-nginx112/nginx/nginx.conf && \
    chmod a+rwx ${APP_ROOT} /etc/opt/rh/rh-nginx112/nginx/nginx.conf && \
    chmod -R a+rwx ${APP_ROOT}/etc && \
    chown -R 1001:0 ${APP_ROOT} && \
    mkdir -p /var/opt/rh/rh-nginx${NGINX_SHORT_VER}/log/nginx && \
    ln -sf /dev/stdout /var/opt/rh/rh-nginx112/log/nginx/access.log && \
    ln -sf /dev/stderr /var/opt/rh/rh-nginx112/log/nginx/error.log && \
    rpm-file-permissions

RUN scl enable rh-python36 "pip3.6 install --upgrade pip" && \
    scl enable rh-python36 "pip3.6 install sphinx"

COPY .s2i/bin/ ${STI_SCRIPTS_PATH}
USER 1001
