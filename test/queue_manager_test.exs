defmodule QueueManagerTest do
  use ExUnit.Case

  test "can start 3 children" do
    response = QueueManager.start_children(3)
    assert %{"SimpleQueue1" => _pid1, "SimpleQueue2" => _pid2, "SimpleQueue3" => _pid3} = response
  end

  test "can list the children" do
    QueueManager.start_children(3)
    response = QueueManager.list_children()
    assert Map.keys(response) == ["SimpleQueue1", "SimpleQueue2", "SimpleQueue3"]
  end

  test "can stop any of the children" do
    QueueManager.start_children(3)

    assert %{"SimpleQueue2" => _pid2, "SimpleQueue3" => _pid3} =
             QueueManager.stop_child("SimpleQueue1")
  end
end
