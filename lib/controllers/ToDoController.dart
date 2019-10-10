import 'package:todo/middlewares/JwtMiddleware.dart';
import 'package:todo/models/ToDo.dart';
import 'package:todo/models/User.dart';
import 'package:todo/todo.dart';

class ToDoController extends ResourceController {
  ToDoController(this.context) {
    acceptedContentTypes = [ContentType.json];
    user = request.attachments['user'] as User;
  }

  User user;
  final ManagedContext context;

  @Operation.get()
  Future<Response> getAllToDos() async {
    final query = await Query<ToDo>(context)
      ..where((todo) => todo.user.id).equalTo(user.id);
    final toDos = await query.fetch();
    return Response.ok(toDos);
  }

  @Operation.get('id')
  Future<Response> getToDoByID() async {
    final id = int.parse(request.path.variables['id']);
    final query = Query<ToDo>(context)
      ..where((todo) => todo.id).equalTo(id)
      ..where((todo) => todo.user.id).equalTo(user.id);
    final toDo = await query.fetchOne();

    if (toDo == null) {
      return Response.notFound();
    }

    return Response.ok(toDo);
  }

  @Operation.post()
  Future<Response> postToDo() async {
    final body = ToDo()..read(await request.body.decode(), ignore: ["id"]);
    final query = Query<ToDo>(context)..values = body;

    final toDo = await query.insert();
    return Response.ok(toDo);
  }

  @Operation.put('id')
  Future<Response> putToDo(@Bind.path("id") int id) async {
    final body = ToDo()..read(await request.body.decode(), ignore: ["id"]);
    final query = Query<ToDo>(context)
      ..values = body
      ..where((todo) => todo.id).equalTo(id)
      ..where((todo) => todo.user.id).equalTo(user.id);
    final toDo = await query.updateOne();
    return Response.ok(toDo);
  }

  @Operation.delete('id')
  Future<Response> deleteToDoByID(@Bind.path("id") int id) async {
    final query = Query<ToDo>(context)
      ..where((todo) => todo.id).equalTo(id)
      ..where((todo) => todo.user.id).equalTo(user.id);
    await query.delete();
    return Response.ok({'ok': true});
  }
}
