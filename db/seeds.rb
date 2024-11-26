user = User.create(name: "Test User")
todo_list = user.todo_lists.create(title: "Groceries")

todo_list.todos.create([
  { title: "Buy milk", status: "pending" },
  { title: "Buy coffee", status: "completed" },
  { title: "Buy chocolate", status: "archived" },
  { title: "Hello u", status: "pending"}
])
