# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# This File if From Theopse (Self@theopse.org)
# Licensed under BSD-3-Caluse
# File:	bvid.ex (Bradot/Library/bvid.ex)
# Content:	Bilibili's Bvid Parser
# Copyright (c) 2021 Theopse Organization All rights reserved
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

defmodule Bradot.Bvid do
  import Standard

  begin "Module Documents" do
    @moduledoc """
      BiliBili's Bvid Parser
    """
  end

  begin "Function Defination" do
    begin D do
      begin {:decode, 1} do
        @doc """
        Parse Bvid to Aid
        (Bvid: https://www.bilibili.com/read/cv5167957)

        ## Examples

            iex> Bradot.Bvid.decode("BV1PE411D7wi")
            70063668
            iex> Bradot.Bvid.decode("BV1ax411d78Z")
            57028349
            iex> Bradot.Bvid.decode("BV1PJ411A727")
            67719840

        """
        @spec decode(bvid) :: :error | integer()
              when bvid: <<_::16, _::_*8>> | charlist()
        def decode(bvid) when is_binary(bvid), do: bvid |> String.to_charlist() |> decode

        def decode([?B, ?V | bvid]) when is_list(bvid) do
          # The Magic String
          # You can see many Magic Item here as the origin auther hadn't give the expression
          # about them when the code have been written
          origin_magic_string = 'fZodR9XQDSUm21yCkr6zBqiveYah8bt4xsWpHnJE7jL5VG3guMTKNPAwcF'

          table =
            origin_magic_string
            |> Enum.with_index()
            |> Map.new()

          table
          |> do_transform(bvid)
          |> Enum.sum()
          # Magic Number * 1
          |> Kernel.-(87_2834_8608)
          # Magic Number * 2
          |> Bitwise.bxor(1_7745_1812)
        end
      end
    end

    begin E do
      begin {:encode, 1} do
        @doc """
        Parse Aid to Bvid
        (Bvid: https://www.bilibili.com/read/cv5167957)

        ## Examples

            iex> Bradot.Bvid.encode(70063668)
            "BV1PE411D7wi"
            iex> Bradot.Bvid.encode(57028349)
            "BV1ax411d78Z"
            iex> Bradot.Bvid.encode(67719840)
            "BV1PJ411A727"

        """

        @spec encode(integer() | binary() | charlist()) :: :error | <<_::16, _::_*8>>
        def encode(aid) when is_binary(aid), do: aid |> String.to_integer() |> encode

        def encode(aid) when is_list(aid),
          do: aid |> Enum.map(&Kernel.-(&1, 48)) |> Enum.join() |> encode

        def encode(aid) when is_integer(aid) do
          # The Magic String
          # You can see many Magic Item here as the origin auther hadn't give the expression
          # about them when the code have been written
          origin_magic_string = 'fZodR9XQDSUm21yCkr6zBqiveYah8bt4xsWpHnJE7jL5VG3guMTKNPAwcF'

          index = [11, 10, 3, 8, 4, 6]

          # The Magic Number
          num =
            aid
            # The Magic Number * 1
            |> Bitwise.bxor(1_7745_1812)
            # The Magic Number * 2
            |> Kernel.+(87_2834_8608)

          for {item, index} <- index |> Enum.with_index(), into: %{} do
            string =
              origin_magic_string
              |> Enum.fetch!(
                num
                |> Kernel./(
                  :math.pow(58, index)
                  |> floor
                )
                |> floor
                |> Integer.mod(58)
              )

            {item, string}
          end
          |> encode_transform
          |> encode_last
        end
      end
    end
  end

  begin "Private SubFunction" do
    defp encode_transform(origin) do
      origin
      |> Enum.all?(&Kernel.!=(&1, :error))
      |> case do
        true ->
          2..11
          |> Enum.map(fn
            2 ->
              ?1

            5 ->
              ?4

            7 ->
              ?1

            9 ->
              ?7

            i ->
              origin
              |> Access.get(i)
          end)

        false ->
          :error
      end
    end

    defp encode_last(:error), do: :error

    defp encode_last(list) when is_list(list) do
      [?B, ?V | list]
      |> String.Chars.List.to_string()
      |> return
    end

    @spec do_transform(map(), charlist()) :: list(integer())
    defp do_transform(table, bvid) when is_map(table),
      do:
        bvid
        |> Enum.with_index()
        |> iterated(table, [])

    @spec iterated(list(), map(), list(integer())) :: list(integer())
    defp iterated([], _, result), do: result
    defp iterated([{head, 9} | tail], table, result), do: iterated(0, head, tail, table, result)
    defp iterated([{head, 8} | tail], table, result), do: iterated(1, head, tail, table, result)
    defp iterated([{head, 1} | tail], table, result), do: iterated(2, head, tail, table, result)
    defp iterated([{head, 6} | tail], table, result), do: iterated(3, head, tail, table, result)
    defp iterated([{head, 2} | tail], table, result), do: iterated(4, head, tail, table, result)
    defp iterated([{head, 4} | tail], table, result), do: iterated(5, head, tail, table, result)
    defp iterated([_ | tail], table, result), do: tail |> iterated(table, result)

    @spec iterated(integer(), char(), list(), map(), list()) :: list(integer())
    defp iterated(i, head, tail, table, result) do
      results =
        table
        |> Access.get(head)
        |> Kernel.*(
          :math.pow(58, i)
          |> floor
        )

      iterated(tail, table, [results | result])
    end
  end
end
