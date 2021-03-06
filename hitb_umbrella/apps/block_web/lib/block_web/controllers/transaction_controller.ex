defmodule BlockWeb.TransactionController do
  use BlockWeb, :controller
  plug BlockWeb.Access
  alias Block
  alias Repos
  alias Block.TransactionService
  @moduledoc """
    Functionality related to blocks in the block chain
  """

  def getTransactions(conn, _) do
    transactions = Block.TransactionRepository.get_all_transactions
    json(conn, %{data: transactions})
  end

  def getTransaction(conn, %{"id" => id}) do
    transaction = Block.TransactionRepository.get_transactions_by_id(id)
    json conn, %{data: transaction}
  end

  def getUnconfirmedTransaction(conn, _) do
    json(conn,  %{})
  end

  def getUnconfirmedTransactions(conn, _) do
    json(conn,  %{})
  end

  def addTransactions(conn, %{"publicKey" => publicKey, "amount" => amount, "recipientId" => recipientId, "message" => message}) do
    %{"secondPassword" => secondPassword} = Map.merge(%{"secondPassword" => "dzc944262316"}, conn.params)
    case TransactionService.newTransaction(%{publicKey: publicKey, amount: String.to_integer(amount), recipientId: recipientId, message: message, secondPassword: secondPassword, fee: 1}) do
      [:ok, transaction, info] -> json(conn,  %{success: true, transaction: transaction, info: info})
      [:error, _, info] -> json(conn,  %{success: false, transaction: [], info: info})
    end
  end

  def getTransactionsByBlockHeight(conn, %{"height" => height}) do
    transaction = Block.TransactionRepository.get_transactions_by_blockIndex(height)
    json conn, %{data: transaction}
  end

  def getTransactionsByBlockHash(conn, %{"hash" => hash}) do
    block = Block.BlockRepository.get_block_by_hash(hash)
    case block do
      [] -> json conn, %{data: []}
      _ -> transaction = Block.TransactionRepository.get_transactions_by_blockIndex(block.index)
           json conn, %{data: transaction}
    end
  end


  def getStorage(conn, _) do
    json(conn,  %{})
  end

  def putStorage(conn, _) do
    json(conn,  %{})
  end
end
