import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'board_data.dart';
import 'board_theme_data.dart';
import 'card_data.dart';
import 'column_data.dart';
import 'label.dart';
import 'milestone.dart';

/// Collection of Kanban board templates.
abstract class BoardTemplates {
  // empty
  static BoardData get empty => BoardData(
        id: Uuid().v4(),
        updated: DateTime.now(),
        title: 'New Board',
      );

  // software
  static BoardData get software => _data.copyWith(
        id: Uuid().v4(),
        updated: DateTime.now(),
      );
  static final Label _aBaLabel = Label(
    label: 'a: ba',
    color: Colors.amber.shade500,
  );
  static final Label _aDesignLabel = Label(
    label: 'a: design',
    color: Colors.amber.shade500,
  );
  static final Label _aDevLabel = Label(
    label: 'a: dev',
    color: Colors.amber.shade500,
  );
  static final Label _aQaLabel = Label(
    label: 'a: qa',
    color: Colors.amber.shade500,
  );
  static final Label _aRelLabel = Label(
    label: 'a: rel',
    color: Colors.amber.shade500,
  );
  static final Label _bHelpWantedLabel = Label(
    label: 'b: help wanted',
    color: Colors.grey.shade500,
  );
  static final Label _bUpstreamLabel = Label(
    label: 'b: upstream',
    color: Colors.grey.shade500,
  );
  static final Label _pCriticalLabel = Label(
    label: 'p: critical',
    color: Colors.red.shade500,
  );
  static final Label _pHigh = Label(
    label: 'p: high',
    color: Colors.red.shade500,
  );
  static final Label _pShowstopperLabel = Label(
    label: 'p: showstopper',
    color: Colors.red.shade500,
  );
  static final Label _sClosedLabel = Label(
    label: 's: closed',
    color: Colors.teal.shade500,
  );
  static final Label _sOpenLabel = Label(
    label: 's: open',
    color: Colors.teal.shade500,
  );
  static final Label _sWontFixLabel = Label(
    label: 's: won\'t fix',
    color: Colors.teal.shade500,
  );
  static final Label _tBugLabel = Label(
    label: 't: bug',
    color: Colors.blue.shade500,
  );
  static final Label _tDocLabel = Label(
    label: 't: doc',
    color: Colors.blue.shade500,
  );
  static final Label _tFeatureLabel = Label(
    label: 't: feature',
    color: Colors.blue.shade500,
  );
  static final Label _tL10nLabel = Label(
    label: 't: l10n',
    color: Colors.blue.shade500,
  );
  static final Label _tOptimizationLabel = Label(
    label: 't: optimization',
    color: Colors.blue.shade500,
  );
  static final Label _tPocLabel = Label(
    label: 't: poc',
    color: Colors.blue.shade500,
  );
  static final Label _tSecurityLabel = Label(
    label: 't: security',
    color: Colors.blue.shade500,
  );
  static final Label _tTestLabel = Label(
    label: 't: test',
    color: Colors.blue.shade500,
  );
  static final Label _tReleaseLabel = Label(
    label: 't: release',
    color: Colors.blue.shade500,
  );
  static final Milestone _pocMilestone = Milestone(name: 'Proof-of-Concept');
  static final Milestone _preview1Milestone = Milestone(name: 'Preview 1');
  static final Milestone _preview2Milestone = Milestone(name: 'Preview 2');
  static final Milestone _alpha1Milestone = Milestone(name: 'Alpha 1');
  static final Milestone _alpha2Milestone = Milestone(name: 'Alpha 2');
  static final Milestone _beta1Milestone = Milestone(name: 'Beta 1');
  static final Milestone _beta2Milestone = Milestone(name: 'Beta 2');
  static final Milestone _rcMilestone = Milestone(name: 'Release Candidate');
  static final Milestone _v1Milestone = Milestone(name: '1.0.0');
  static final BoardData _data = BoardData(
    title: 'New Board',
    columns: [
      ColumnData(
        title: 'To Do',
        limit: 24,
        cards: [
          CardData(
            title: 'Sample Task',
            labels: {
              _aDevLabel,
              _sOpenLabel,
              _tPocLabel,
            },
            milestone: _pocMilestone,
          ),
        ],
      ),
      ColumnData(
        title: 'Doing',
        limit: 3,
      ),
      ColumnData(
        title: 'Done',
        limit: 99,
      ),
    ],
    labels: {
      _aBaLabel,
      _aDesignLabel,
      _aDevLabel,
      _aQaLabel,
      _aRelLabel,
      _bHelpWantedLabel,
      _bUpstreamLabel,
      _pCriticalLabel,
      _pHigh,
      _pShowstopperLabel,
      _sClosedLabel,
      _sOpenLabel,
      _sWontFixLabel,
      _tBugLabel,
      _tDocLabel,
      _tFeatureLabel,
      _tL10nLabel,
      _tOptimizationLabel,
      _tPocLabel,
      _tReleaseLabel,
      _tSecurityLabel,
      _tTestLabel,
    },
    milestones: {
      _pocMilestone,
      _preview1Milestone,
      _preview2Milestone,
      _alpha1Milestone,
      _alpha2Milestone,
      _beta1Milestone,
      _beta2Milestone,
      _rcMilestone,
      _v1Milestone,
    },
  );

  // weekly
  static BoardData get weekly => _weekly.copyWith(
        id: Uuid().v4(),
        updated: DateTime.now(),
      );
  static final Label _importantLabel = Label(
    label: 'important',
    color: Colors.red.shade500,
  );
  static final Label _recurringLabel = Label(
    label: 'recurring',
    color: Colors.orange.shade500,
  );
  static final BoardData _weekly = BoardData(
    title: 'New Board',
    columns: [
      ColumnData(
        title: 'Monday',
        color: Colors.indigo.shade600,
        cards: [
          CardData(
            title: 'Sample Task',
            labels: {
              _importantLabel,
              _recurringLabel,
            },
          ),
        ],
      ),
      ColumnData(
        title: 'Tuesday',
        color: Colors.indigo.shade500,
      ),
      ColumnData(
        title: 'Wednesday',
        color: Colors.indigo.shade400,
      ),
      ColumnData(
        title: 'Thursday',
        color: Colors.indigo.shade300,
      ),
      ColumnData(
        title: 'Friday',
        color: Colors.lightBlue.shade200,
      ),
      ColumnData(
        title: 'Saturday / Sunday',
        color: Colors.lightBlue.shade100,
      ),
    ],
    labels: {
      _importantLabel,
      _recurringLabel,
    },
    theme: BoardThemeData(cardColor: Colors.indigoAccent.shade100),
  );

  // quarterly
  static BoardData get quarterly => _quarterly.copyWith(
        id: Uuid().v4(),
        updated: DateTime.now(),
      );
  static final BoardData _quarterly = BoardData(
    title: 'New Board',
    columns: [
      ColumnData(
        title: 'Q1',
        cards: [
          CardData(
            title: 'Sample Task',
            labels: {_importantLabel},
          ),
        ],
      ),
      ColumnData(title: 'Q2'),
      ColumnData(title: 'Q3'),
      ColumnData(title: 'Q4'),
    ],
    labels: {_importantLabel},
  );
}
