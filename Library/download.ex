# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# This File if From Theopse (Self@theopse.org)
# Licensed under BSD-3-Caluse
# File:	video.ex (Bradot/Library/video.ex)
# Content:	Bilibili's Video API
# Copyright (c) 2021 Theopse Organization All rights reserved
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

defmodule Bradot.Download do
  import Standard

  begin "Dependance Require" do
    import Bradot.HTTP
  end

  begin "Function Defination" do
    begin :_ do
      begin {:__loop__, 3} do
        def __loop__(state, ref, fun) do
          receive do
            {from, ^ref, :change, new_fun} ->
              send(from, {self(), ref, :ok})
              __loop__(state, ref, new_fun)
            {from, ^ref, :run, arg} ->
              result = fun.(state, arg)
              send(from, {self(), ref, {:ok, result}})
              __loop__(state, ref, fun)
            {from, ^ref, :stop} ->
              send(from, {self(), ref, :ok})
              exit(:STOP)
          end
        end
      end
    end
    begin G do
      begin {:general, [1,2]} do
        def general(url, otps \\ []) do
          self = :erlang.self()
          ref = :erlang.make_ref()
          headers = headers(otps)

          recv = fn _, %HTTPoison.AsyncResponse{id: id} = resp ->
            receive do
              %HTTPoison.AsyncStatus{id: ^id, code: _} ->
                HTTPoison.stream_next(resp)
                :next
              %HTTPoison.AsyncHeaders{id: ^id} ->
                HTTPoison.stream_next(resp)
                :next
              %HTTPoison.AsyncChunk{id: ^id, chunk: chunk} ->
                HTTPoison.stream_next(resp)
                chunk
              %HTTPoison.AsyncEnd{id: ^id} ->
                :halt
            end
          end

          start = fn ->
            pid = spawn(__MODULE__, :__loop__, [nil, ref, recv])
            {pid, ref, HTTPoison.get!(url, headers, ssl: [{:versions, [:"tlsv1.2", :"tlsv1.1", :tlsv1]}], recv_timeout: :infinity, stream_to: pid, async: :once)}
          end

          handle = fn {pid, ref, resp} ->
            send(pid, {self, ref, :run, resp})
            receive do
              {^pid, ^ref, {:ok, result}} ->
                case result do
                  :halt ->
                    {:halt, {pid, ref, resp}}
                  :next ->
                    {[], {pid, ref, resp}}
                  chunk ->
                    {[chunk], {pid, ref, resp}}
                end
            end

          end

          ends = fn {pid, ref, %HTTPoison.AsyncResponse{id: id}} ->
            :hackney.stop_async(id)
            send(pid, {self, ref, :stop})
          end

          Stream.resource(start, handle, ends)
        end
      end
    end
  end
end
