docker run -d \
  --name alloy-toward-ot1 \
  -p 12345:12345 \
  -v "/Users/masahiro.kawakami/repositories/nyukin-observation/logs:/logs" \
  -v "/Users/masahiro.kawakami/repositories/nyukin-observation/alloy/config.alloy:/etc/alloy/config.alloy" \
  -v "/Users/masahiro.kawakami/repositories/nyukin-observation/alloy/tk.domain.cer:/etc/ssl/certs/tk.domain.cer" \
  -v alloy-positions:/var/lib/alloy/positions \
  grafana/alloy:latest \
  run --server.http.listen-addr=0.0.0.0:12345 --storage.path=/var/lib/alloy/data /etc/alloy/config.alloy