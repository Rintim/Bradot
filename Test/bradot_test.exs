defmodule BradotTest do
  use ExUnit.Case
  doctest Bradot.Bvid

  import Standard

  left do
    "Test Video Info"
    [
      "70063668": "[Rintim]圆滚滚进化论 伪HE3+全BE剧情（更新中）",
      "57028349": "[Rintim]圆滚滚进化论可继续发展/NE线不唯一攻略视频（持续更新中）",
      "67719840": "「究极剧透」Rintim|圆滚滚生产学全BE/NE/HE/TE"
    ]
    "（別問為啥全是我的視頻/-/）"
  end

  @avid [
    70063668,
    57028349,
    67719840
  ]

  @bvid [
    "BV1PE411D7wi",
    "BV1ax411d78Z",
    "BV1PJ411A727"
  ]

  test "Bvid Encode" do
    Stream.zip(@avid, @bvid)
    |> Enum.all?(fn {aid, bvid} ->
      Bradot.Bvid.encode(aid) == bvid
    end)
    |> assert
  end

  test "Bvid Decode" do
    Stream.zip(@avid, @bvid)
    |> Enum.all?(fn {aid, bvid} ->
      aid == Bradot.Bvid.decode(bvid)
    end)
    |> assert
  end

  test "Info Get" do
    Enum.each(@avid, fn aid ->
      Bradot.Video.getInfo(aid)
    end)
    true
  end

  test "Private API Test" do
    Stream.map(@avid, fn aid ->
      {aid, Bradot.Video.getInfo(aid)}
    end)
    |> Enum.each(fn {aid, [title: _, pages: pages]} ->
      pages
      |> Enum.each(fn %{"cid" => cid} ->
        Bradot.Video.getLinks(aid, cid, 80)
      end)
    end)
  end

  test "Public API Test" do
    Stream.map(@avid, fn aid ->
      {aid, Bradot.Video.getInfo(aid)}
    end)
    |> Enum.each(fn {aid, [title: _, pages: pages]} ->
      pages
      |> Enum.each(fn %{"cid" => cid} ->
        Bradot.Video.getLinks(aid, cid, 80, "Non Sessdata But Could For Test", mp4?: true)
        Bradot.Video.getLinks(aid, cid, 80, "Non Sessdata But Could For Test")
      end)
    end)
  end

  test "Cover Get" do
    Enum.each(@avid, fn aid ->
      Bradot.Video.getCoverLink(aid)
    end)
  end

  test "Quality Get" do
    Stream.map(@avid, fn aid ->
      {aid, Bradot.Video.getInfo(aid)}
    end)
    |> Enum.each(fn {aid, [title: _, pages: pages]} ->
      pages
      |> Enum.each(fn %{"cid" => cid} ->
        Bradot.Video.getCurrentQuality(aid, cid, 80, "Non Sessdata But Could For Test")
      end)
    end)
  end

  test "Quality Get in Private API" do
    Stream.map(@avid, fn aid ->
      {aid, Bradot.Video.get_info(aid)}
    end)
    |> Enum.each(fn {aid, [title: _, pages: pages]} ->
      pages
      |> Enum.each(fn %{"cid" => cid} ->
        Bradot.Video.getCurrentQuality(aid, cid, 80)
      end)
    end)
  end

  test "Download Test" do
    Stream.map(@avid, fn aid ->
      Bradot.Video.getCoverLink(aid)
    end)
    |> Enum.map(fn url ->
      Bradot.Download.general(url)
      |> Stream.into(File.stream!(".test.jpg"))
      |> Stream.run()
    end)
    File.rm(".test.jpg")
  end
end
