# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# This File if From Theopse (Self@theopse.org)
# Licensed under BSD-3-Caluse
# File:	http.ex (bradot/lib/http.ex)
# Content:	HTTP
# Copyright (c) 2021 Theopse Organization All rights reserved
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

defmodule Bradot.HTTP do

  import Standard
  def ssl, do: [ssl: [{:versions, [:"tlsv1.2", :"tlsv1.1", :tlsv1]}]]

  def headers do
    [
      "User-Agent": user_agent()
    ]
  end

  def headers(otps) do
    Enum.reduce(otps, ["User-Agent": user_agent()], fn otp, headers ->
      case otp do
        {:userAgent, false} ->
          List.keydelete(headers, :"User-Agent", 0)
        {:userAgent, item} ->
          List.keyreplace(headers, :"User-Agent", 0, {:"User-Agent", item})
        {:"user-agent", false} ->
          List.keydelete(headers, :"User-Agent", 0)
        {:"user-agent", item} ->
          List.keyreplace(headers, :"User-Agent", 0, {:"User-Agent", item})
        {:referer, item} ->
          [{:Referer, item} | headers]
        {:cookies, list} when list?(list) ->
          headers
        {:cookies, item} ->
          [{:Cookie, item} | headers]
        {:host, item} ->
          [{:Host, item} | headers]
        _ ->
          headers
      end
    end)
  end

  def user_agent do
    :random.uniform(4)
    |> case do
      1 ->
        "Mozilla/5.0 (X11; FreeBSD amd64; rv:81.0) Gecko/20100101 Firefox/81.0"

      2 ->
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.16; rv:81.0) Gecko/20100101 Firefox/81.0"

      3 ->
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:81.0) Gecko/20100101 Firefox/81.0"

      4 ->
        "Mozilla/5.0 (X11; FreeBSD arm64; rv:81.0) Gecko/20100101 Firefox/81.0"
    end
  end
end
