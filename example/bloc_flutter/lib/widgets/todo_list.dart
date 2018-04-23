// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:bloc_flutter_sample/dependency_injection.dart';
import 'package:bloc_flutter_sample/screens/detail_screen.dart';
import 'package:bloc_flutter_sample/widgets/todos_bloc_provider.dart';
import 'package:bloc_flutter_sample/widgets/loading.dart';
import 'package:bloc_flutter_sample/widgets/todo_item.dart';
import 'package:blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture_samples/flutter_architecture_samples.dart';

class TodoList extends StatelessWidget {
  TodoList({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<List<Todo>>(
      stream: TodosBlocProvider.of(context).visibleTodos,
      builder: (context, snapshot) => snapshot.hasData
          ? _buildList(snapshot.data)
          : new LoadingSpinner(key: ArchSampleKeys.todosLoading),
    );
  }

  ListView _buildList(List<Todo> todos) {
    return new ListView.builder(
      key: ArchSampleKeys.todoList,
      itemCount: todos.length,
      itemBuilder: (BuildContext context, int index) {
        final todo = todos[index];

        return new TodoItem(
          todo: todo,
          onDismissed: (direction) {
            _removeTodo(context, todo);
          },
          onTap: () {
            Navigator.of(context).push(
              new MaterialPageRoute(
                builder: (_) {
                  return new DetailScreen(
                    todoId: todo.id,
                    buildBloc: () =>
                        new TodoBloc(Injector.of(context).todosInteractor),
                  );
                },
              ),
            ).then((todo) {
              if (todo is Todo) {
                _showUndoSnackbar(context, todo);
              }
            });
          },
          onCheckboxChanged: (complete) {
            TodosBlocProvider
                .of(context)
                .updateTodo
                .add(todo.copyWith(complete: !todo.complete));
          },
        );
      },
    );
  }

  void _removeTodo(BuildContext context, Todo todo) {
    TodosBlocProvider.of(context).deleteTodo.add(todo.id);

    _showUndoSnackbar(context, todo);
  }

  void _showUndoSnackbar(BuildContext context, Todo todo) {
    final snackBar = new SnackBar(
      key: ArchSampleKeys.snackbar,
      duration: new Duration(seconds: 2),
      backgroundColor: Theme.of(context).backgroundColor,
      content: new Text(
        ArchSampleLocalizations.of(context).todoDeleted(todo.task),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      action: new SnackBarAction(
        key: ArchSampleKeys.snackbarAction(todo.id),
        label: ArchSampleLocalizations.of(context).undo,
        onPressed: () {
          TodosBlocProvider.of(context).addTodo.add(todo);
        },
      ),
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }
}