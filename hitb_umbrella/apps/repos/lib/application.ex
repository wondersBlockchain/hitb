defmodule Repos.Application do
  @moduledoc """
  The Repos Application Service.

  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    initialize_datastore()
    children = []
    opts = [strategy: :one_for_one, name: Repos.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def initialize_datastore() do
    initialize_db()
    :ets.new(:peers, [:set, :public, :named_table])
    :ets.new(:latest_block, [:set, :public, :named_table])
    generate_initial_block()
  end

  defp initialize_db() do
    :mnesia.start()
    :ok = :mnesia.wait_for_tables([:block_chain], 5000)
  end

  defp generate_initial_block() do
    :mnesia.clear_table(:block_chain)
    init_block = %Repos.Block{
      index: 0,
      previous_hash: "0",
      timestamp: :os.system_time(:seconds),
      data: "foofizzbazz",
      hash: :crypto.hash(:sha256, "cool") |> Base.encode64
    }
    init_transaction = %Repos.Transaction{
      id: 0,
      height: init_block.index,
      blockId: to_string(init_block.index),
      type:                 3,
      timestamp:            init_block.timestamp,
      senderPublicKey:      address = :crypto.hash(:sha256, "someone manual strong movie roof episode eight spatial brown soldier soup motor")|> Base.encode64,
      requesterPublicKey:   "SYSTEM",
      senderId:             "",
      recipientId:          "",
      amount:               0,
      fee:                  0,
      signature:            "",
      signSignature:       "",
      asset:                %{},
      args:                 {},
      message:              "创世区块"
    }
    :mnesia.transaction(fn ->
      case :mnesia.read({:block_chain, 0}) do
        [] ->
          :mnesia.write({:block_chain,
            init_block.index,
            init_block.previous_hash,
            init_block.timestamp,
            init_block.data,
            init_block.hash})
            :ets.insert(:latest_block, {:latest, init_block})
          :mnesia.write({:transaction,
            init_transaction.id,
            init_transaction.height,
            init_transaction.blockId,
            init_transaction.type,
            init_transaction.timestamp,
            init_transaction.senderPublicKey,
            init_transaction.requesterPublicKey,
            init_transaction.senderId,
            init_transaction.recipientId,
            init_transaction.amount,
            init_transaction.fee,
            init_transaction.signature,
            init_transaction.signSignature,
            init_transaction.asset,
            init_transaction.args,
            init_transaction.message})
        _ ->
          :ok
      end
    end)
  end
end
