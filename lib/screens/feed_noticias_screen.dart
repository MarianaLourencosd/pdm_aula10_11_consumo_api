import 'package:flutter/material.dart';
import '../models/noticia_model.dart';
import '../services/noticia_service.dart';
import 'detalhe_noticia_screen.dart';

class FeedNoticiasScreen extends StatefulWidget {
  const FeedNoticiasScreen({super.key});

  @override
  State<FeedNoticiasScreen> createState() => _FeedNoticiasScreenState();
}

class _FeedNoticiasScreenState extends State<FeedNoticiasScreen> {
  final _service = NoticiaService();
  final TextEditingController _buscaController = TextEditingController();

  List<NoticiaModel> _noticias = [];
  List<NoticiaModel> _noticiasFiltradas = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarFeed();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarFeed() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final lista = await _service.buscarNoticias();
      setState(() {
        _noticias = lista;
        _aplicarFiltro();
      });
    } catch (e) {
      setState(() => _erro = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _carregando = false);
    }
  }

  void _aplicarFiltro() {
    final termo = _buscaController.text.toLowerCase();
    _noticiasFiltradas = termo.isEmpty
        ? List.from(_noticias)
        : _noticias
            .where((n) => n.titulo.toLowerCase().contains(termo))
            .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed de Notícias'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarFeed,
          ),
        ],
      ),
      body: _buildConteudo(),
    );
  }

  Widget _buildConteudo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_erro!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _carregarFeed,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _buscaController,
            decoration: const InputDecoration(
              labelText: 'Filtrar notícias por título',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(_aplicarFiltro),
          ),
        ),
        Expanded(
          child: _noticiasFiltradas.isEmpty
              ? const Center(child: Text('Nenhuma notícia encontrada.'))
              : ListView.builder(
                  itemCount: _noticiasFiltradas.length,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final noticia = _noticiasFiltradas[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(noticia.id.toString()),
                        ),
                        title: Text(
                          noticia.titulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          noticia.resumo,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetalheNoticiaScreen(noticia: noticia),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
