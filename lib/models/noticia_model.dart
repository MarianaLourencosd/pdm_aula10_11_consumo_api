class NoticiaModel {
  final int id;
  final int autorId;
  final String titulo;
  final String resumo;
  final String conteudoCompleto;
  final String autor;
  final String urlImagem;

  NoticiaModel({
    required this.id,
    required this.autorId,
    required this.titulo,
    required this.resumo,
    required this.conteudoCompleto,
    required this.autor,
    required this.urlImagem,
  });

  factory NoticiaModel.fromJson(Map<String, dynamic> json) {
    final corpo = json['body'] ?? 'Sem conteúdo disponível.';
    return NoticiaModel(
      id: json['id'] ?? 0,
      autorId: json['userId'] ?? 0,
      titulo: json['title'] ?? 'Sem título',
      resumo: corpo.length > 40 ? '${corpo.substring(0, 40)}...' : corpo,
      conteudoCompleto: corpo,
      autor: 'Autor ID ${json['userId'] ?? 1}',
      urlImagem: 'https://picsum.photos/seed/${json['id']}/600/300',
    );
  }
}
