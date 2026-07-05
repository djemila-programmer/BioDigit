import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'farm_service.dart';
import 'history_service.dart';
import 'anomaly_service.dart';

/// Excel report generation service for biodigester monitoring data.
class ExcelService {
  /// Generate a complete Excel report with multiple sheets.
  Future<String> generateReport({
    required FarmData farm,
    required ProductionSummary production,
    required AnomalyReport anomaly,
    required List<HistoryPoint> historyData,
    required String period,
  }) async {
    final excel = Excel.createExcel();

    // ─── Sheet 1: Farm Information ──────────────────────────────────────
    _createFarmSheet(excel, farm);

    // ─── Sheet 2: Production Summary ────────────────────────────────────
    _createProductionSheet(excel, production, period);

    // ─── Sheet 3: Sensor Analysis ───────────────────────────────────────
    _createSensorSheet(excel, anomaly);

    // ─── Sheet 4: History Data ──────────────────────────────────────────
    _createHistorySheet(excel, historyData);

    // ─── Sheet 5: Anomaly Analysis ──────────────────────────────────────
    _createAnomalySheet(excel, anomaly);

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'biodigester_report_${period}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final filePath = '${directory.path}/$fileName';
    final bytes = excel.save();
    if (bytes != null) {
      await File(filePath).writeAsBytes(bytes);
    }
    return filePath;
  }

  void _createFarmSheet(Excel excel, FarmData farm) {
    final sheetName = 'Ferme';
    excel.rename('Sheet1', sheetName);
    final sheet = excel[sheetName];

    // Header
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('BioSmart Africa — Rapport Ferme');
    sheet.cell(CellIndex.indexByString('A1')).cellStyle = _headerStyle();
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('D1'));

    // Farm info
    final data = [
      ['Nom', farm.name],
      ['Localisation', farm.location],
      ['Type Biodigesteur', farm.biodigesterType],
      ['Capacité', '${farm.biodigesterCapacity} m³'],
      ['Statut', farm.status],
      ['Vaches', farm.cows.toString()],
      ['Porcs', farm.pigs.toString()],
      ['Chèvres', farm.goats.toString()],
      ['Volaille', farm.poultry.toString()],
      ['Production Déchets', '${farm.wasteProduction} kg/jour'],
      ['Énergie Produite', '${farm.energyProduction} kWh'],
    ];

    for (var i = 0; i < data.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 3)).value = TextCellValue(data[i][0]);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 3)).value = TextCellValue(data[i][1]);
    }

    // Auto-width
    sheet.setColumnWidth(0, 25);
    sheet.setColumnWidth(1, 40);
  }

  void _createProductionSheet(Excel excel, ProductionSummary production, String period) {
    final sheetName = 'Production';
    final sheet = excel[sheetName];

    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Résumé de Production — ${_periodLabel(period)}');
    sheet.cell(CellIndex.indexByString('A1')).cellStyle = _headerStyle();
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('C1'));

    final data = [
      ['Métrique', 'Valeur', 'Unité'],
      ['Volume Produit', production.volume.toStringAsFixed(1), 'm³'],
      ['Efficacité', production.efficiency.toStringAsFixed(1), '%'],
      ['Énergie Générée', production.energyGenerated.toStringAsFixed(1), 'kWh'],
      ['Réduction CO₂', production.co2Reduction.toStringAsFixed(2), 'tons'],
      ['Nombre de Relevés', production.readingCount.toString(), ''],
    ];

    for (var i = 0; i < data.length; i++) {
      for (var j = 0; j < data[i].length; j++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 3)).value = TextCellValue(data[i][j]);
      }
    }

    sheet.setColumnWidth(0, 25);
    sheet.setColumnWidth(1, 20);
    sheet.setColumnWidth(2, 15);
  }

  void _createSensorSheet(Excel excel, AnomalyReport anomaly) {
    final sheetName = 'Capteurs';
    final sheet = excel[sheetName];

    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Analyse des Capteurs');
    sheet.cell(CellIndex.indexByString('A1')).cellStyle = _headerStyle();
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('D1'));

    // Headers
    final headers = ['Capteur', 'Valeur', 'Statut', 'Message'];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 2)).value = TextCellValue(headers[i]);
    }

    // Data
    for (var i = 0; i < anomaly.sensorResults.length; i++) {
      final r = anomaly.sensorResults[i];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 3)).value = TextCellValue('${r.sensorName} (${r.sensorId})');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 3)).value = TextCellValue('${r.value.toStringAsFixed(1)} ${r.unit}');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 3)).value = TextCellValue(r.status);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 3)).value = TextCellValue(r.message);
    }

    sheet.setColumnWidth(0, 25);
    sheet.setColumnWidth(1, 15);
    sheet.setColumnWidth(2, 15);
    sheet.setColumnWidth(3, 50);
  }

  void _createHistorySheet(Excel excel, List<HistoryPoint> historyData) {
    final sheetName = 'Historique';
    final sheet = excel[sheetName];

    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Historique des Relevés');
    sheet.cell(CellIndex.indexByString('A1')).cellStyle = _headerStyle();
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('E1'));

    // Headers
    final headers = ['Date/Heure', 'Température (°C)', 'Pression (bar)', 'Méthane (ppm)', 'Lisier (%)'];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 2)).value = TextCellValue(headers[i]);
    }

    // Data
    for (var i = 0; i < historyData.length; i++) {
      final h = historyData[i];
      final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(h.timestamp);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 3)).value = TextCellValue(dateStr);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 3)).value = DoubleCellValue(h.temperature);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 3)).value = DoubleCellValue(h.pressure);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 3)).value = DoubleCellValue(h.methane);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 3)).value = DoubleCellValue(h.slurryLevel);
    }

    sheet.setColumnWidth(0, 20);
    sheet.setColumnWidth(1, 18);
    sheet.setColumnWidth(2, 15);
    sheet.setColumnWidth(3, 15);
    sheet.setColumnWidth(4, 15);
  }

  void _createAnomalySheet(Excel excel, AnomalyReport anomaly) {
    final sheetName = 'Anomalies';
    final sheet = excel[sheetName];

    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Analyse d\'Anomalies');
    sheet.cell(CellIndex.indexByString('A1')).cellStyle = _headerStyle();
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('B1'));

    final data = [
      ['Score de Santé', '${anomaly.healthScore}/100'],
      ['Score de Risque', '${anomaly.riskScore}/100'],
      ['Niveau de Sévérité', anomaly.severityLevel],
      ['Confiance de Prédiction', '${anomaly.predictionConfidence.toStringAsFixed(1)}%'],
      ['Anomalies Détectées', anomaly.sensorAnomalies.toString()],
      ['Actions Recommandées', anomaly.recommendedActions.toString()],
    ];

    for (var i = 0; i < data.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 3)).value = TextCellValue(data[i][0]);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 3)).value = TextCellValue(data[i][1]);
    }

    // Actions section
    final actionsStartRow = data.length + 5;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: actionsStartRow)).value = TextCellValue('Actions Recommandées');
    for (var i = 0; i < anomaly.actions.length; i++) {
      final action = anomaly.actions[i];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: actionsStartRow + i + 1)).value = TextCellValue('[${action.priority}] ${action.title}');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: actionsStartRow + i + 1)).value = TextCellValue(action.description);
    }

    sheet.setColumnWidth(0, 30);
    sheet.setColumnWidth(1, 50);
  }

  CellStyle _headerStyle() {
    return CellStyle(bold: true);
  }

  String _periodLabel(String period) {
    switch (period) {
      case 'daily': return 'Journalier';
      case 'weekly': return 'Hebdomadaire';
      case 'monthly': return 'Mensuel';
      case 'annual': return 'Annuel';
      default: return period;
    }
  }
}
