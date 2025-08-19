FROM nginx:stable-alpine
LABEL maintainer="tmaior"
COPY . /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF && git add Dockerfile && git commit -m "chore: add Dockerfile to serve static frontend via nginx" && git push origin HEAD:main && git log --stat -1 && cat Dockerfile
