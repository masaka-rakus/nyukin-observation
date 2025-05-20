docker run -d \
  --name alloy-toward-ot1 \
  -p 12345:12345 \
  -v "$(pwd)/logs:/logs" \
  -v "$(pwd)/alloy/config.alloy:/etc/alloy/config.alloy" \
  -v "$(pwd)/alloy/tk.domain.cer:/etc/ssl/certs/tk.domain.cer" \
  -v alloy-positions:/var/lib/alloy/positions \
  grafana/alloy:latest \
  run --server.http.listen-addr=0.0.0.0:12345 --storage.path=/var/lib/alloy/data /etc/alloy/config.alloy