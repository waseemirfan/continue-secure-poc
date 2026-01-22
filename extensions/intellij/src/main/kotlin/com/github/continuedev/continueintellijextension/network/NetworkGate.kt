package com.github.continuedev.continueintellijextension.network

import java.net.InetAddress

object NetworkGate {

  private val allowedCidrs = listOf(
    "127.0.0.0/8",
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  )

  init {
    // PoC visibility hook – proves IntelliJ side is secured
    println("Continue Secure Mode: NetworkGate active")
  }

  fun checkHost(host: String) {
    val addr = try {
      InetAddress.getByName(host)
    } catch (e: Exception) {
      throw SecurityException("NETWORK_GATE: DNS blocked")
    }

    val ip = addr.hostAddress
    if (allowedCidrs.none { cidrMatch(ip, it) }) {
      throw SecurityException("NETWORK_GATE: host not allowed")
    }
  }

  private fun cidrMatch(ip: String, cidr: String): Boolean {
    val (net, len) = cidr.split("/")
    val ipNum = ipToNum(ip)
    val netNum = ipToNum(net)
    val mask = -1 shl (32 - len.toInt())
    return (ipNum and mask) == (netNum and mask)
  }

  private fun ipToNum(ip: String): Int =
    ip.split(".").fold(0) { acc, v -> (acc shl 8) + v.toInt() }
}
