# SIPIS 24h Monitoring Checklist

## Goal
Validate stability of SIPIS registration, push delivery, and network path for 24 hours.

## Sampling interval
- Every 5 minutes for registration and contact state
- Every 15 minutes for firewall/drop counters
- After each user push test event

## Capture points
1. SIPIS host (`95.81.122.254` equivalent)
2. PBX endpoints (both sides if multi-PBX)
3. SIPIS database (`pushtests`, selectors/tokens)

## Commands

### A. SIPIS state
```bash
curl -s --digest -u 'admin:<password>' http://127.0.0.1:5000/stats
docker logs --since 10m sipis 2>&1 | grep -Ei 'register loop|registered|error|timeout|cannot connect|about-to-register'
```

### B. Edge/tunnel state
```bash
docker logs --since 10m stunnelsipis 2>&1 | tail -n 100
docker logs --since 10m lb2 2>&1 | tail -n 100
```

### C. PBX contact state
```bash
asterisk -rx 'pjsip show contacts'
grep -E 'AOR .*201|AOR .*611|Failed to authenticate|REGISTER' /var/log/asterisk/full | tail -n 100
```

### D. Firewall counters
```bash
iptables -vnL RUFILTER
iptables -vnL DOCKER-USER | head -n 40
```

### E. Push DB metrics
```bash
docker exec dbsipis psql -U sipis -d sipis -c \
"select platform,count(*) total,count(concluded) succeeded,count(*)-count(concluded) pending_or_failed from pushtests group by platform;"
```

## Pass criteria
1. Account rows in `/stats` remain `Register Loop / Registered` (not `Error`/`NotRegistered` for long windows).
2. PBX contacts for SIPIS-driven accounts remain `Avail` with short recovery if app sleeps.
3. No recurring `Cannot Connect` / TLS fatal bursts in SIPIS logs.
4. Push tests produce increasing `succeeded` without long pending backlog growth.
5. Firewall drop counters do not increase for required push ports (`4998/24998`) path.

## Alert criteria
- Repeated `Register Loop / Error` for > 3 consecutive intervals
- PBX contact flapping > 6 times/hour per account
- Push `pending_or_failed` growth > 5 in 1 hour
- Any new drop growth on rules that should be bypassed for push ports

## Notes
- GeoIP filtering is enabled; push ports are explicitly bypassed.
- Admin web access is restricted by source IP policy.
