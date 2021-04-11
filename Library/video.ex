# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# This File if From Theopse (Self@theopse.org)
# Licensed under BSD-3-Caluse
# File:	video.ex (Bradot/Library/video.ex)
# Content:	Bilibili's Video API
# Copyright (c) 2021 Theopse Organization All rights reserved
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

defmodule Bradot.Video do
  import Standard
  import Bradot.HTTP

  begin "Module Documents" do
    @moduledoc """
    Bilibili's Video API.
    """
  end

  begin "Function Defination" do
    begin G do
      begin {:get_cover_link, 1} do
        def get_cover_link(vid) when binary?(vid),
          do:
            translate(vid)
            |> get_cover_link()

        def get_cover_link(aid) do
          url = "https://www.bilibili.com/video/av#{aid}"

          with {:ok, %HTTPoison.Response{body: body}} <- HTTPoison.get(url, headers(), ssl()),
               html = :zlib.gunzip(body),
               result =
                 Regex.named_captures(
                   ~r/<script>window.__INITIAL_STATE__=(?<html>.*?);.+<\/script>/,
                   html
                 ),
               json = Access.get(result, "html"),
               {:ok, map} <- JSON.decode(json) do
            map
            |> Access.get("videoData")
            |> Access.get("pic")
          end
        end
      end

      begin {:get_current_quality, 3} do
        def get_current_quality(vid, cid, quality),
          do: get_current_quality_in_private(vid, cid, quality)
      end

      begin {:get_current_quality, 4} do
        def get_current_quality(vid, cid, quality, sessdata) when binary?(vid),
          do:
            translate(vid)
            |> get_current_quality(cid, quality, sessdata)

        def get_current_quality(aid, cid, quality, sessdata) do
          url = "https://api.bilibili.com/x/player/playurl?cid=#{cid}&avid=#{aid}&qn=#{quality}"

          with {:ok, %HTTPoison.Response{body: body}} <-
                 HTTPoison.get(
                   url,
                   headers(cookies: "SESSDATA=#{sessdata};", host: "api.bilibili.com"),
                   ssl()
                 ),
               {:ok, json} <- JSON.decode(body) do
            json
            |> Access.get("data")
            |> Access.get("quality")
          end
        end
      end

      begin {:get_current_quality_in_private, 3} do
        def get_current_quality_in_private(vid, cid, quality) when binary?(vid),
          do:
            translate(vid)
            |> get_current_quality_in_private(cid, quality)

        def get_current_quality_in_private(aid, cid, quality) do
          with {:ok, %HTTPoison.Response{body: body}} <- private_api(aid, cid, quality),
               {:ok, json} <- JSON.decode(body) do
            json
            |> Access.get("quality")
          end
        end
      end

      begin {:get_info, 1} do
        def get_info(vid) when binary?(vid),
          do:
            translate(vid)
            |> get_info()

        def get_info(aid) do
          url = "https://api.bilibili.com/x/web-interface/view?aid=#{aid}"

          with {:ok, %HTTPoison.Response{body: body}} <-
                 HTTPoison.get(
                   url,
                   Bradot.HTTP.headers(),
                   Bradot.HTTP.ssl()
                 ),
               {:ok, json} <- JSON.decode(body) do
            data =
              json
              |> Access.get("data")

            [
              title:
                data
                |> Access.get("title"),
              pages:
                data
                |> Access.get("pages")
            ]
          end
        end
      end

      begin {:get_links, 3} do
        @spec get_links(any, any, any) :: list | {atom, any}
        def get_links(vid, cid, quality), do: get_links_in_private(vid, cid, quality)
      end

      begin {:get_links, {4, 5}} do
        def get_links(vid, cid, quality, sessdata, otps \\ nil)

        def get_links(vid, cid, quality, sessdata, otps) when binary?(vid),
          do:
            translate(vid)
            |> get_links(cid, quality, sessdata, otps)

        def get_links(aid, cid, quality, sessdata, otps) do
          url =
            if otps && Access.get(otps, :mp4?, false) do
              "https://api.bilibili.com/x/player/playurl?cid=#{cid}&avid=#{aid}&qn=#{quality}&type=&otype=json&fnver=0&fnval=16&fourk=1&platform=html5&high_quality=1"
            else
              "https://api.bilibili.com/x/player/playurl?cid=#{cid}&avid=#{aid}&qn=#{quality}"
            end

          headers =
            Bradot.HTTP.headers(cookies: "SESSDATA=#{sessdata};", host: "api.bilibili.com")

          HTTPoison.get(url, headers, Bradot.HTTP.ssl())
          |> case do
            {:ok, %HTTPoison.Response{body: body}} ->
              with {:ok, json} <- JSON.decode(body) do
                json
                |> Access.get("data")
                |> Access.get("durl")
                |> Enum.map(&Access.get(&1, "url"))
              end
          end
        end
      end

      begin {:get_links_in_private, 3} do
        @spec get_links_in_private(any, any, any) :: list | {atom, any}
        def get_links_in_private(vid, cid, quality) when binary?(vid),
          do:
            translate(vid)
            |> get_links_in_private(cid, quality)

        def get_links_in_private(aid, cid, quality) do
          with {:ok, %HTTPoison.Response{body: body}} <- private_api(aid, cid, quality),
               {:ok, json} <- JSON.decode(body) do
            Access.get(json, "durl")
            |> Enum.map(&Access.get(&1, "url"))
          end
        end
      end
    end
  end

  begin "Function Aliases" do
    def getCoverLink(vid), do: get_cover_link(vid)
    def getCurrentQuality(vid, cid, quality), do: get_current_quality_in_private(vid, cid, quality)
    def getCurrentQuality(vid, cid, quality, sessdata), do: get_current_quality(vid, cid, quality, sessdata)
    def getCurrentQualityInPrivate(vid, cid, quality), do: get_current_quality_in_private(vid, cid, quality)
    def getInfo(vid), do: get_info(vid)
    def getLinks(vid, cid, quality), do: get_links_in_private(vid, cid, quality)
    def getLinks(vid, cid, quality, sessdata, otps \\ nil), do: get_links(vid, cid, quality, sessdata, otps)
    def getLinksInPrivate(vid, cid, quality), do: get_links_in_private(vid, cid, quality)
  end

  begin "Private SubFunction" do
    defp translate(vid) do
      if(Regex.match?(~r/^BV/, vid), do: Bradot.Bvid.decode(vid), else: vid)
      |> String.to_integer()
    end

    defp private_api(aid, cid, quality) do
      [appkey, sec] =
        'rbMCKn@KuamXWlPMoJGsKcbiJKUfkPF_8dABscJntvqhRSETg'
        |> Enum.reverse()
        |> Enum.map(&(&1 + 2))
        |> to_string
        |> String.split(":")

      params = "appkey=#{appkey}&cid=#{cid}&otype=json&qn=#{quality}&quality=#{quality}&type="

      chksum =
        :crypto.hash(:md5, <<params::binary, sec::binary>>)
        |> Base.encode16(case: :lower)

      url = "https://interface.bilibili.com/v2/playurl?#{params}&sign=#{chksum}"

      HTTPoison.get(
        url,
        headers(referer: "https://api.bilibili.com/x/web-interface/view?aid=#{aid}"),
        ssl()
      )
    end
  end
end
