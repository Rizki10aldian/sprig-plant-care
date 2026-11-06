import 'dart:math' as math;
import 'dart:typed_data';

/// Satu bagian model 3D yang bisa bergoyang sendiri (mis. satu daun beserta
/// tangkainya). Bagian pot bersifat diam (amp = 0).
class MeshPart {
  MeshPart({
    required this.vertices,
    required this.indices,
    required this.colors,
    required this.amp,
    required this.speed,
    required this.phase,
    required this.pivotX,
    required this.pivotY,
    required this.pivotZ,
    required this.axisX,
    required this.axisY,
    required this.axisZ,
  });

  /// x,y,z berurutan untuk setiap titik.
  final Float64List vertices;

  /// tiga indeks titik untuk setiap segitiga.
  final Int32List indices;

  /// warna ARGB dasar untuk setiap segitiga.
  final Int32List colors;

  final double amp;
  final double speed;
  final double phase;
  final double pivotX;
  final double pivotY;
  final double pivotZ;
  final double axisX;
  final double axisY;
  final double axisZ;

  int get vertexCount => vertices.length ~/ 3;
  int get triangleCount => indices.length ~/ 3;

  static MeshPart fromJson(Map<String, dynamic> json) {
    final v = (json['v'] as List<dynamic>).map((e) => (e as num).toDouble());
    final i = (json['i'] as List<dynamic>).map((e) => (e as num).toInt());
    final c = (json['c'] as List<dynamic>).map((e) => (e as num).toInt());
    final sw = (json['sw'] as List<dynamic>).map((e) => (e as num).toDouble()).toList();
    final axisLen = math.sqrt(sw[6] * sw[6] + sw[7] * sw[7] + sw[8] * sw[8]);
    final k = axisLen == 0 ? 0.0 : 1 / axisLen;
    return MeshPart(
      vertices: Float64List.fromList(v.toList()),
      indices: Int32List.fromList(i.toList()),
      colors: Int32List.fromList(c.toList()),
      amp: sw[0],
      speed: sw[1],
      phase: sw[2],
      pivotX: sw[3],
      pivotY: sw[4],
      pivotZ: sw[5],
      axisX: sw[6] * k,
      axisY: sw[7] * k,
      axisZ: sw[8] * k,
    );
  }
}

/// Model 3D low-poly: kumpulan [MeshPart] dengan ukuran muat ([fit]) dan
/// tinggi pusat ([cy]) agar mudah diletakkan di tengah kanvas.
class Model3D {
  Model3D({required this.fit, required this.cy, required this.parts}) {
    var total = 0;
    var verts = 0;
    for (final p in parts) {
      total += p.triangleCount;
      verts += p.vertexCount;
    }
    triangleCount = total;
    vertexCount = verts;
  }

  final double fit;
  final double cy;
  final List<MeshPart> parts;
  late final int triangleCount;
  late final int vertexCount;

  static Model3D fromJson(Map<String, dynamic> json) {
    return Model3D(
      fit: (json['fit'] as num).toDouble(),
      cy: (json['cy'] as num).toDouble(),
      parts: (json['parts'] as List<dynamic>)
          .map((e) => MeshPart.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

/// Hasil satu kali render: posisi layar (x,y) dan warna ARGB tiap titik
/// segitiga, sudah terurut dari yang terjauh. Dipakai langsung oleh
/// `Canvas.drawVertices`.
class RenderBuffers {
  RenderBuffers(int triangles)
      : positions = Float32List(triangles * 6),
        colors = Int32List(triangles * 3);

  final Float32List positions;
  final Int32List colors;

  /// Posisi layar titik pusat dasar model (untuk bayangan lantai).
  double baseX = 0;
  double baseY = 0;

  /// Skala piksel per satuan model pada titik dasar.
  double unit = 1;
}

/// Perender software sederhana (algoritma pelukis): putar, goyangkan tiap
/// bagian, proyeksi perspektif, beri cahaya, urutkan dari jauh ke dekat.
class Renderer3D {
  Renderer3D(this.model)
      : _vx = Float64List(model.vertexCount),
        _vy = Float64List(model.vertexCount),
        _vz = Float64List(model.vertexCount),
        _depth = Float64List(model.triangleCount),
        _shade = Int32List(model.triangleCount),
        _order = List<int>.generate(model.triangleCount, (i) => i),
        _triPart = Int32List(model.triangleCount),
        _triLocal = Int32List(model.triangleCount),
        buffers = RenderBuffers(model.triangleCount) {
    var t = 0;
    for (var p = 0; p < model.parts.length; p++) {
      final n = model.parts[p].triangleCount;
      for (var k = 0; k < n; k++) {
        _triPart[t] = p;
        _triLocal[t] = k;
        t++;
      }
    }
  }

  final Model3D model;
  final RenderBuffers buffers;

  final Float64List _vx;
  final Float64List _vy;
  final Float64List _vz;
  final Float64List _depth;
  final Int32List _shade;
  final List<int> _order;
  final Int32List _triPart;
  final Int32List _triLocal;

  static const double cameraDistance = 7.0;

  // Arah cahaya (menuju sumber) dalam ruang kamera, sudah dinormalkan.
  static final double _lx = -0.45 / _lightLen;
  static final double _ly = 0.80 / _lightLen;
  static final double _lz = 0.55 / _lightLen;
  static final double _lightLen =
      math.sqrt(0.45 * 0.45 + 0.8 * 0.8 + 0.55 * 0.55);

  /// [time] detik, [yaw]/[pitch] radian, [width]/[height] piksel kanvas.
  RenderBuffers render({
    required double time,
    required double yaw,
    required double pitch,
    required double width,
    required double height,
  }) {
    final cy = math.cos(yaw);
    final sy = math.sin(yaw);
    final cp = math.cos(pitch);
    final sp = math.sin(pitch);
    // G = Rx(pitch) * Ry(yaw)
    final g00 = cy;
    final g01 = 0.0;
    final g02 = sy;
    final g10 = sp * sy;
    final g11 = cp;
    final g12 = -sp * cy;
    final g20 = -cp * sy;
    final g21 = sp;
    final g22 = cp * cy;

    var offset = 0;
    for (final part in model.parts) {
      final n = part.vertexCount;
      final v = part.vertices;
      // Matriks goyangan (Rodrigues) bila bagian ini bergerak.
      var r00 = 1.0, r01 = 0.0, r02 = 0.0;
      var r10 = 0.0, r11 = 1.0, r12 = 0.0;
      var r20 = 0.0, r21 = 0.0, r22 = 1.0;
      final sway = part.amp != 0;
      if (sway) {
        final a = part.amp * math.sin(time * part.speed + part.phase);
        final c = math.cos(a);
        final s = math.sin(a);
        final k = 1 - c;
        final x = part.axisX;
        final y = part.axisY;
        final z = part.axisZ;
        r00 = c + x * x * k;
        r01 = x * y * k - z * s;
        r02 = x * z * k + y * s;
        r10 = y * x * k + z * s;
        r11 = c + y * y * k;
        r12 = y * z * k - x * s;
        r20 = z * x * k - y * s;
        r21 = z * y * k + x * s;
        r22 = c + z * z * k;
      }
      for (var i = 0; i < n; i++) {
        var x = v[i * 3];
        var y = v[i * 3 + 1];
        var z = v[i * 3 + 2];
        if (sway) {
          final dx = x - part.pivotX;
          final dy = y - part.pivotY;
          final dz = z - part.pivotZ;
          x = r00 * dx + r01 * dy + r02 * dz + part.pivotX;
          y = r10 * dx + r11 * dy + r12 * dz + part.pivotY;
          z = r20 * dx + r21 * dy + r22 * dz + part.pivotZ;
        }
        y -= model.cy;
        _vx[offset + i] = g00 * x + g01 * y + g02 * z;
        _vy[offset + i] = g10 * x + g11 * y + g12 * z;
        _vz[offset + i] = g20 * x + g21 * y + g22 * z;
      }
      offset += n;
    }

    // Cahaya + kedalaman tiap segitiga.
    var vOff = 0;
    var t = 0;
    for (final part in model.parts) {
      final idx = part.indices;
      final cols = part.colors;
      final nt = part.triangleCount;
      for (var k = 0; k < nt; k++) {
        final a = vOff + idx[k * 3];
        final b = vOff + idx[k * 3 + 1];
        final c = vOff + idx[k * 3 + 2];
        final ux = _vx[b] - _vx[a];
        final uy = _vy[b] - _vy[a];
        final uz = _vz[b] - _vz[a];
        final wx = _vx[c] - _vx[a];
        final wy = _vy[c] - _vy[a];
        final wz = _vz[c] - _vz[a];
        var nx = uy * wz - uz * wy;
        var ny = uz * wx - ux * wz;
        var nz = ux * wy - uy * wx;
        final len = math.sqrt(nx * nx + ny * ny + nz * nz);
        if (len > 1e-12) {
          nx /= len;
          ny /= len;
          nz /= len;
        }
        if (nz < 0) {
          nx = -nx;
          ny = -ny;
          nz = -nz;
        }
        var diff = nx * _lx + ny * _ly + nz * _lz;
        if (diff < 0) diff = 0;
        final kLight = 0.50 + 0.52 * diff + 0.07 * ny;
        final base = cols[k];
        var rr = ((base >> 16) & 255) * kLight;
        var gg = ((base >> 8) & 255) * kLight;
        var bb = (base & 255) * kLight;
        if (kLight > 1.0) {
          var f = (kLight - 1.0) * 0.9;
          if (f > 0.35) f = 0.35;
          rr += (255 - rr) * f;
          gg += (255 - gg) * f;
          bb += (255 - bb) * f;
        }
        _shade[t] = 0xFF000000 |
            (_clamp255(rr) << 16) |
            (_clamp255(gg) << 8) |
            _clamp255(bb);
        _depth[t] = (_vz[a] + _vz[b] + _vz[c]) / 3;
        t++;
      }
      vOff += part.vertexCount;
    }

    _order.sort((p, q) => _depth[p].compareTo(_depth[q]));

    final scale = math.min(width, height) / (model.fit * 1.12);
    final cxs = width / 2;
    final cys = height / 2;
    final pos = buffers.positions;
    final col = buffers.colors;
    var o = 0;
    for (var n = 0; n < _order.length; n++) {
      final tri = _order[n];
      final part = model.parts[_triPart[tri]];
      final local = _triLocal[tri];
      final partOffset = _partOffset(_triPart[tri]);
      final color = _shade[tri];
      for (var e = 0; e < 3; e++) {
        final vi = partOffset + part.indices[local * 3 + e];
        final f = cameraDistance / (cameraDistance - _vz[vi]);
        pos[o * 2] = cxs + _vx[vi] * f * scale;
        pos[o * 2 + 1] = cys - _vy[vi] * f * scale;
        col[o] = color;
        o++;
      }
    }

    // Titik dasar model (0,0,0) setelah diputar, untuk bayangan lantai.
    final by = -model.cy;
    final bx0 = g01 * by;
    final by0 = g11 * by;
    final bz0 = g21 * by;
    final bf = cameraDistance / (cameraDistance - bz0);
    buffers.baseX = cxs + bx0 * bf * scale;
    buffers.baseY = cys - by0 * bf * scale;
    buffers.unit = scale * bf;
    return buffers;
  }

  late final List<int> _offsets = _computeOffsets();

  List<int> _computeOffsets() {
    final list = <int>[];
    var o = 0;
    for (final p in model.parts) {
      list.add(o);
      o += p.vertexCount;
    }
    return list;
  }

  int _partOffset(int part) => _offsets[part];

  static int _clamp255(double v) {
    if (v < 0) return 0;
    if (v > 255) return 255;
    return v.round();
  }
}
