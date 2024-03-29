import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:praiabarraca/componentes/form_comanda.dart';
import 'package:praiabarraca/componentes/mensagem_lista_vazia.dart';
import 'package:praiabarraca/modelos/comanda.dart';
import 'package:praiabarraca/modelos/estabelecimento.dart';
import 'package:praiabarraca/telas/tela_fechamento_comanda.dart';
import 'package:praiabarraca/telas/tela_pedidos.dart';

class ListaComandas extends StatelessWidget {
  final Estabelecimento estabelecimento;
  ListaComandas(this.estabelecimento);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder(
        stream: Firestore.instance
            .collection('caixas')
            .document(estabelecimento.idCaixaAtual)
            .collection('comandas')
            .where('isAberto', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshots) {
          if (!snapshots.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshots.data.documents.length == 0) {
            return MensagemListaVazia('Nenhuma comanda aberta');
          }
          return ListView.builder(
            itemCount: snapshots.data.documents.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = snapshots.data.documents[index];
              return Card(
                elevation: 5,
                child: ListTile(
                  leading: CircleAvatar(
                      child: FittedBox(
                    child: Text(doc.documentID),
                  )),
                  title: Text(
                    '${doc['nomeCliente']}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  isThreeLine: true,
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 3),
                      Text(
                        'Celular: ${doc['telefoneCliente']}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Total: R\$${doc['total']}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Abertura: ${DateFormat('H:mm').format((doc['abertura'] as Timestamp).toDate())}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.indigo,
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                builder: (_) {
                                  return FormComanda(
                                    idCaixa: estabelecimento.idCaixaAtual,
                                    idComanda: doc.documentID,
                                    nome: doc['nomeCliente'],
                                    telefone: doc['telefoneCliente'],
                                  );
                                });
                          }),
                      IconButton(
                          icon: Icon(
                            Icons.receipt,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            Comanda comanda = new Comanda(
                              id: int.tryParse(doc.documentID.toString()),
                              nomeCliente: doc['nomeCliente'],
                              telefoneCliente:
                                  doc['telefoneCliente'].toString(),
                              isAberto: false,
                              abertura: (doc['abertura'] as Timestamp).toDate(),
                            );
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TelaFechamentoComanda(
                                    estabelecimento, comanda),
                              ),
                            );
                          }),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TelaPedidos(
                          estabelecimento: estabelecimento,
                          idComanda: doc.documentID,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
