defmodule Block.PeerService do
  require Logger

  alias Block.PeerRepository
  @moduledoc """
  Documentation for Peers.
  """
  def hello do
    :world
  end

  def getPublicIp do
    publicIp = nil
    publicIp
  end

  def newPeer(host, port)do
    peer = %{host: host, port: port, connect: true}
    PeerRepository.insert_peer(peer)
  end

end
