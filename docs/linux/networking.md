# Network troubleshooting: name → route → port → protocol

Run connectivity checks only against approved targets. Set the actual host and port; `example.com` / `db.example.com` are documentation placeholders.

## 1. Local configuration

**Observe**

```bash
ip -br address
ip route
ip -s link
```

Look for the expected interface, address, route, and unusual error counters. A link being up does not establish an end-to-end path. On NetworkManager systems, `nmcli device status` is an additional view; it is not available everywhere.

## 2. Name resolution

**Observe**

```bash
getent ahosts example.com
dig example.com A
dig example.com AAAA
```

`getent` follows the system's name-service configuration; `dig` queries DNS. Different answers can result from hosts files, split DNS, caches, search domains, or application-specific resolution. `dig` is optional (`dnsutils` on many Debian systems, `bind-utils` on many RHEL systems).

Compare the resolved address with the expected destination. Test IPv4 and IPv6 separately when only one path fails. Do not replace the organization's DNS servers as an initial guess.

## 3. Routing and transport

**Observe / connectivity probe — replace the destination.**

```bash
ip route get 192.0.2.10
ping -c 3 192.0.2.10
nc -vz -w 3 db.example.com 3306
```

`192.0.2.10` is a reserved example address, not a reachable test host. `nc` flags depend on the implementation; check `nc -h` first. Ping failure may only mean ICMP is filtered. A successful TCP connection proves a socket accepted the connection, not that database authentication or a query works.

On the server, inspect the actual listening address and port:

```bash
ss -lnt
ss -lntp
```

Process details may need elevated access. A service bound only to `127.0.0.1` is not listening on the server's external interface. A timeout can come from several points in the path; “connection refused” can mean no listener or an explicit reject. Neither result alone identifies the responsible component.

## 4. Application protocol

**Observe / HTTP probe — use an approved, lightweight health URL.**

```bash
curl --head --connect-timeout 3 --max-time 10 https://example.com/
```

HEAD may not be implemented by every endpoint. Check the application's documented health request if needed. A `401`/`403` is an authentication/authorization response; a proxy-generated `502`/`504` points to an upstream path to investigate. HTTP success alone may not exercise the user's failing feature.

For TLS failures, check hostname, certificate validity and chain, client trust, and system time. Do not hide certificate failures by disabling validation. For MySQL, continue with [its connection checks](../mysql/commands.md).

Sources: [ss manual](https://man7.org/linux/man-pages/man8/ss.8.html), [Red Hat networking](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html-single/configuring_and_managing_networking/index), and installed `man ip`, `man getent`, `man dig`, `man nc`, and `man curl` pages.
