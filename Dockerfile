FROM node:18-alpine
WORKDIR /app
COPY package*.json ./

RUN npm ci 

COPY . .

RUN addgroup -g 1001 -S team
RUN adduser -S team -u 1001

RUN chown -R team:team /app
USER team

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

ENTRYPOINT ["npm"]
CMD ["start"]