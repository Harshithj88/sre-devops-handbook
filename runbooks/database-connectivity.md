# Runbook: Database Connectivity Issues

## Purpose

This runbook provides steps to diagnose and resolve application failures caused by database connectivity problems, including connection timeouts, authentication failures, and connection pool exhaustion.

## Symptoms

- Application returns HTTP 500 errors with database-related error messages
- Connection timeout errors in application logs
- "Too many connections" or connection pool exhaustion errors
- Slow queries causing request timeouts
- Authentication or permission denied errors
- Database failover or replication lag alerts

## Impact

Partial or complete service degradation depending on the application's database dependency and fallback behavior.

## Initial Checks

```bash
# Test direct database connectivity
# SQL Server
sqlcmd -S <server> -U <user> -P <password> -Q "SELECT 1"
Test-NetConnection -ComputerName <db-server> -Port 1433

# PostgreSQL
psql -h <host> -U <user> -d <database> -c "SELECT 1"

# MySQL
mysql -h <host> -u <user> -p -e "SELECT 1"

# Check DNS resolution for database hostname
nslookup <db-hostname>
```

## Investigation Steps

### 1. Check application connection errors

```bash
# Search application logs for database errors
kubectl logs <pod-name> -n <namespace> --tail=200 | grep -i "sql\|database\|connection\|timeout"

# IIS / Windows
Get-EventLog -LogName Application -Newest 50 | Where-Object { $_.Message -match "SQL|database|connection" }
```

### 2. Check connection pool status

```sql
-- SQL Server: Check active connections
SELECT
    DB_NAME(dbid) AS DatabaseName,
    COUNT(dbid) AS ConnectionCount,
    loginame AS LoginName
FROM sys.sysprocesses
GROUP BY dbid, loginame
ORDER BY ConnectionCount DESC;

-- SQL Server: Check for blocked sessions
SELECT
    blocking_session_id,
    session_id,
    wait_type,
    wait_time,
    wait_resource
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0;

-- PostgreSQL: Check active connections
SELECT datname, count(*) FROM pg_stat_activity GROUP BY datname;

-- PostgreSQL: Check max connections
SHOW max_connections;
```

### 3. Check database server health

```sql
-- SQL Server: Check server status
SELECT @@SERVERNAME AS ServerName, @@VERSION AS Version;
SELECT * FROM sys.dm_os_performance_counters
WHERE counter_name IN ('User Connections', 'Batch Requests/sec', 'Buffer cache hit ratio');

-- PostgreSQL
SELECT pg_is_in_recovery(); -- true if replica
SELECT * FROM pg_stat_database WHERE datname = current_database();
```

### 4. Check network connectivity

```bash
# Test TCP connectivity to database port
Test-NetConnection -ComputerName <db-server> -Port 1433
Test-NetConnection -ComputerName <db-server> -Port 5432

# Trace route to database server
tracert <db-server>

# Check firewall rules (Azure)
az network nsg rule list --nsg-name <nsg-name> -g <resource-group> -o table
```

### 5. Check for long-running queries

```sql
-- SQL Server: Find long-running queries
SELECT
    r.session_id,
    r.start_time,
    DATEDIFF(SECOND, r.start_time, GETDATE()) AS duration_seconds,
    r.status,
    t.text AS query_text
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.status = 'running'
ORDER BY duration_seconds DESC;

-- PostgreSQL: Find long-running queries
SELECT pid, now() - pg_stat_activity.query_start AS duration, query, state
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY duration DESC;
```

### 6. Check disk space on database server

```sql
-- SQL Server: Check database file sizes
SELECT
    DB_NAME(database_id) AS DatabaseName,
    name AS FileName,
    type_desc,
    size * 8 / 1024 AS SizeMB,
    CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT) * 8 / 1024 AS UsedMB
FROM sys.master_files
ORDER BY SizeMB DESC;
```

## Resolution Options

| Root Cause | Resolution |
|---|---|
| Connection pool exhausted | Increase pool size, fix connection leaks, restart application |
| Database server down | Restart database service, failover to replica |
| Network connectivity | Check firewall rules, NSG rules, VNet peering |
| Authentication failure | Verify credentials, check password expiry, reset password |
| Long-running queries | Kill blocking queries, optimize slow queries, add indexes |
| Disk space full | Expand disk, shrink log files, archive old data |
| Max connections reached | Increase max connections, close idle connections, scale up |
| Replication lag | Check replica health, verify network between primary and replica |
| DNS resolution failure | Check DNS records, flush DNS cache, verify DNS server |

## Temporary Mitigation

```sql
-- SQL Server: Kill a blocking session (use with caution)
KILL <session_id>;

-- PostgreSQL: Terminate a blocking query
SELECT pg_terminate_backend(<pid>);
```

```bash
# Restart application pods to reset connection pools
kubectl rollout restart deployment/<deployment-name> -n <namespace>

# IIS: Recycle application pool
Restart-WebAppPool -Name <pool-name>
```

## Escalation

| Role | Contact |
|---|---|
| Application Owner | [Team/Contact] |
| DBA Team | [Team/Contact] |
| Network/Infrastructure | [Team/Contact] |

## Post-Incident Follow-Up

- [ ] Document incident timeline
- [ ] Identify root cause
- [ ] Review connection pool settings
- [ ] Optimize slow queries if applicable
- [ ] Add or improve database monitoring and alerting
- [ ] Update this runbook
