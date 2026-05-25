import 'package:flutter/material.dart';
import 'package:registagrodriver/theme/app_theme.dart';

class TripCard extends StatefulWidget {
  final String fazenda;
  final String status;
  final String origem;
  final String destino;
  final String quantidade;
  final String produto;
  final String oferta;
  final VoidCallback onIniciar;
  final String photo;

  const TripCard({
    super.key,
    required this.fazenda,
    required this.status,
    required this.origem,
    required this.destino,
    required this.quantidade,
    required this.produto,
    required this.oferta,
    required this.onIniciar,
    required this.photo
  });

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard>
    with SingleTickerProviderStateMixin {
  bool _expandido = false;
  bool _viagemIniciada = false;
  bool _viagemFinalizada = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;

  bool get _isPendente => widget.status.toLowerCase().trim() == 'pendente';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _toggle() {
    setState(() => _expandido = !_expandido);
    _expandido ? _controller.forward() : _controller.reverse();
  }

  void _onIniciarViagem() {
    if (_isPendente) {
      _mostrarNotificacaoPendente();
      return;
    }
    setState(() => _viagemIniciada = true);
  }

  void _onFinalizarCorrida() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Finalizar corrida'),
        content: const Text('Tem certeza que deseja finalizar esta corrida?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _viagemFinalizada = true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  void _mostrarNotificacaoPendente() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.orange.shade700,
        duration: const Duration(seconds: 3),
        content: Row(
          children: const [
            Icon(Icons.hourglass_top_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Aceite a viagem para poder iniciá-la',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _statusAtual {
    if (_viagemFinalizada) return 'Entregue';
    if (_viagemIniciada) return 'Em andamento';
    return widget.status;
  }

  Color get _statusBgColor {
    switch (_statusAtual.toLowerCase()) {
      case 'entregue':
        return Colors.blue.shade100;
      case 'em andamento':
      case 'confirmado':
        return Colors.green.shade100;
      case 'pendente':
      default:
        return Colors.orange.shade100;
    }
  }

  Color get _statusTextColor {
    switch (_statusAtual.toLowerCase()) {
      case 'entregue':
        return Colors.blue.shade700;
      case 'em andamento':
      case 'confirmado':
        return Colors.green.shade700;
      case 'pendente':
      default:
        return Colors.orange.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 231, 231, 231)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Color.fromARGB(255, 214, 213, 213),
                        backgroundImage: widget.photo != ""
                            ? NetworkImage(widget.photo)
                            : null,
                        child: widget.photo == ""
                            ? const Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.fazenda,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: REGISTheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusBgColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _statusAtual,
                          style: TextStyle(
                            color: _statusTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      RotationTransition(
                        turns: _rotateAnimation,
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Column(
              children: [
                const Divider(
                  height: 1,
                  color: Color.fromARGB(255, 231, 231, 231),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 20,
                                color: Colors.grey,
                              ),
                              Column(
                                children: List.generate(
                                  7,
                                  (_) => Container(
                                    height: 5,
                                    width: 1,
                                    color: Colors.grey,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 1,
                                    ),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.place_outlined,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _LocalInfo(
                                label: 'De onde vais sair ?',
                                valor: widget.origem,
                              ),
                              const SizedBox(height: 30),
                              _LocalInfo(
                                label: 'Para onde vamos ?',
                                valor: widget.destino,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _Metrica(
                            label: 'Quantidade',
                            valor: widget.quantidade,
                          ),
                          _Metrica(label: 'Produto', valor: widget.produto),
                          _Metrica(label: 'Oferta', valor: widget.oferta),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!_viagemFinalizada && widget.status.toLowerCase() != 'entregue')
            Padding(
              padding: const EdgeInsets.all(15),
              child: _viagemIniciada
                  ? Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: widget.onIniciar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.map_outlined, size: 18),
                                SizedBox(width: 6),
                                Text('Ver no mapa'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _onFinalizarCorrida,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline, size: 18),
                                SizedBox(width: 6),
                                Text('Finalizar'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: _onIniciarViagem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: REGISTheme.surface,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Iniciar viagem'),
                        ],
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

class _LocalInfo extends StatelessWidget {
  final String label;
  final String valor;
  const _LocalInfo({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          valor,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _Metrica extends StatelessWidget {
  final String label;
  final String valor;
  const _Metrica({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.circle, color: Colors.grey, size: 8),
            const SizedBox(width: 3),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        Text(
          valor,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
