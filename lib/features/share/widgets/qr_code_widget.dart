import 'package:flutter/material.dart';
import 'package:trtravel/core/constants/app_colors.dart';
import 'package:trtravel/core/constants/app_radius.dart';

class QRCodeWidget extends StatelessWidget {
  final String data;
  final double size;

  const QRCodeWidget({
    super.key,
    required this.data,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    final cells = _generateMatrix(data);

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: CustomPaint(
        size: Size(size - 24, size - 24),
        painter: _QRPainter(cells: cells, cellSize: (size - 24) / cells.length),
      ),
    );
  }

  List<List<bool>> _generateMatrix(String input) {
    final size = 11;
    final matrix = List.generate(size, (_) => List.filled(size, false));

    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (i == 0 || i == size - 1 || j == 0 || j == size - 1) {
          matrix[i][j] = true;
        }
      }
    }

    matrix[0][0] = true;
    matrix[0][size - 1] = true;
    matrix[size - 1][0] = true;
    matrix[size - 1][size - 1] = true;

    final hash = data.hashCode;
    for (int i = 1; i < size - 1; i++) {
      for (int j = 1; j < size - 1; j++) {
        final bit = (hash >> ((i * size + j) % 32)) & 1;
        matrix[i][j] = bit == 1;
      }
    }

    return matrix;
  }
}

class _QRPainter extends CustomPainter {
  final List<List<bool>> cells;
  final double cellSize;

  _QRPainter({required this.cells, required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.textPrimary;
    final bgPaint = Paint()..color = Colors.white;

    for (int i = 0; i < cells.length; i++) {
      for (int j = 0; j < cells[i].length; j++) {
        final rect = Rect.fromLTWH(
          j * cellSize,
          i * cellSize,
          cellSize,
          cellSize,
        );
        canvas.drawRect(rect, cells[i][j] ? paint : bgPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QRPainter oldDelegate) => cells != oldDelegate.cells;
}
