import 'package:github/server.dart';
import 'package:args/args.dart';
import 'package:logging/logging.dart';

final Logger _logger = new Logger('code_checker_test');

main(List<String> args) {
  print(args);
  _setupLogger();

  var parser = new ArgParser()
    ..addOption('out',
        abbr: 'o',
        help: 'When the result should be send',
        allowed: ['stdout', 'github'],
        defaultsTo: 'stdout')
    ..addOption('pull-request-id',
        help: 'the ID of the concerned pull request on Github',
        defaultsTo: '0')
    ..addOption('token', help: 'the github auth token', defaultsTo: '')
    ..addOption('repo',
        help: 'the github repository : user/name',
        defaultsTo: 'xavierhainaux/code_checker_test');

  var argResults = parser.parse(args);

  if (argResults['out'] == 'github') {
    _logger.warning('Post to github');

    String finalComment = ':white_check_mark: ${new DateTime.now()}';

    print(argResults['pull-request-id']);
    postCommentOnGithub(
        repository: argResults['repo'],
        token: argResults['token'],
        pullRequestId: int.parse(argResults['pull-request-id']),
        comment: finalComment);
  }
}

postCommentOnGithub({String repository, String token, int pullRequestId,
    String comment}) async {
  try {
    var github = createGitHubClient(auth: new Authentication.withToken(token));

    List repoUserName = repository.split('/');
    var repoSlug = new RepositorySlug(repoUserName.first, repoUserName.last);
    await github.issues.createComment(repoSlug, pullRequestId, comment);
  } catch (e) {
    _logger.severe('Cannot post on github $e');
  }
}

_setupLogger() {
  Logger logger = Logger.root;
  logger.onRecord.where((r) => r.level >= Level.INFO).listen((LogRecord entry) {
    String stacktrace = entry.stackTrace != null ? '\n${entry.stackTrace}' : '';

    print(
        "${entry.level.name} - ${entry.loggerName}: ${entry.message}$stacktrace");
  });
}
