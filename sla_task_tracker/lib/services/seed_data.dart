import '../models/activity_log_entry.dart';
import '../models/task.dart';
import '../models/task_priority.dart';
import '../models/team_member.dart';

/// Demo data used only the very first time the app runs (when local
/// storage is empty). After that, everything the user sees comes from
/// what they create, edit or complete — the dashboard counts and SLA
/// badges are always computed live, never hardcoded.
class SeedData {
  SeedData._();

  static List<TeamMember> members() {
    return const [
      TeamMember(
        id: 'm1',
        name: 'Stephanie Uwera',
        email: 'stephanie.uwera@smart.com',
        role: 'Senior Security Engineer',
        team: 'Platform Security',
        location: 'Kigali',
        avatarColorValue: 0xFFFFC9B9,
        isAvailable: true,
      ),
      TeamMember(
        id: 'm2',
        name: 'Michael Chen',
        email: 'michael.chen@smart.com',
        role: 'Lead Backend Engineer',
        team: 'Platform Security',
        location: 'Kigali',
        avatarColorValue: 0xFFB8C4FF,
        isAvailable: true,
      ),
      TeamMember(
        id: 'm3',
        name: 'Elena Rodriguez',
        email: 'elena.rodriguez@smart.com',
        role: 'SLA Compliance Specialist',
        team: 'Governance',
        location: 'Remote',
        avatarColorValue: 0xFFFFE0A3,
        isAvailable: false,
      ),
      TeamMember(
        id: 'm4',
        name: 'Sarah Achieng',
        email: 'sarah.achieng@smart.com',
        role: 'Security Program Manager',
        team: 'Platform Security',
        location: 'Kigali',
        avatarColorValue: 0xFFC9EFC2,
        isAvailable: true,
      ),
      TeamMember(
        id: 'm5',
        name: 'Daniel Mugisha',
        email: 'daniel.mugisha@smart.com',
        role: 'Mobile Engineer',
        team: 'Product Engineering',
        location: 'Kigali',
        avatarColorValue: 0xFFE6C6FF,
        isAvailable: true,
      ),
    ];
  }

  static List<Task> tasks() {
    final now = DateTime.now();
    return [
      // Already overdue.
      Task(
        id: 'T-101',
        title: 'Resolve Gateway Timeout Alerts',
        description:
            'Investigate repeated 504 responses from the API gateway under '
            'load and apply a fix. Includes updating retry/backoff config '
            'and verifying with a soak test.',
        category: 'Cloud Migration',
        startDate: now.subtract(const Duration(days: 6)),
        dueDate: now.subtract(const Duration(days: 1)),
        priority: TaskPriority.critical,
        assigneeId: 'm2',
        createdAt: now.subtract(const Duration(days: 6)),
      ),
      // Inside its "at risk" window (High = 8h).
      Task(
        id: 'T-102',
        title: 'Refactor Auth Service Logic',
        description:
            'Review and refactor the authentication service logic to close '
            'audit findings and align permission handling with the current '
            'SLA framework.',
        category: 'Security Audit Q4',
        startDate: now.subtract(const Duration(days: 3)),
        dueDate: now.add(const Duration(hours: 4, minutes: 12)),
        priority: TaskPriority.high,
        assigneeId: 'm1',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      // Comfortably on track.
      Task(
        id: 'T-103',
        title: 'Update UI Component Library',
        description:
            'Bring the shared component library in line with the new '
            'design tokens: spacing, color roles and typography scale.',
        category: 'Design System V2',
        startDate: now.subtract(const Duration(days: 2)),
        dueDate: now.add(const Duration(days: 6)),
        priority: TaskPriority.medium,
        assigneeId: 'm5',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      // On track, low priority, long runway.
      Task(
        id: 'T-104',
        title: 'Review ETL Pipeline Monitoring',
        description:
            'Audit current ETL monitoring dashboards and alerts, and '
            'document gaps in coverage for the data platform team.',
        category: 'Data Platform',
        startDate: now.subtract(const Duration(days: 1)),
        dueDate: now.add(const Duration(days: 10)),
        priority: TaskPriority.low,
        assigneeId: 'm4',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      // Already completed.
      Task(
        id: 'T-100',
        title: 'Rotate Service Account Credentials',
        description:
            'Rotate and re-provision service account credentials for the '
            'staging environment following the quarterly security review.',
        category: 'Security Audit Q4',
        startDate: now.subtract(const Duration(days: 9)),
        dueDate: now.subtract(const Duration(days: 4)),
        priority: TaskPriority.high,
        assigneeId: 'm1',
        createdAt: now.subtract(const Duration(days: 9)),
        isCompleted: true,
        completedAt: now.subtract(const Duration(days: 5)),
      ),
      // At risk soon (Medium = 24h window).
      Task(
        id: 'T-105',
        title: 'Finalize Incident Response Runbook',
        description:
            'Document the step-by-step runbook for P1 incidents, including '
            'escalation paths and on-call rotation handoff.',
        category: 'Platform Reliability',
        startDate: now.subtract(const Duration(days: 4)),
        dueDate: now.add(const Duration(hours: 20)),
        priority: TaskPriority.medium,
        assigneeId: 'm4',
        createdAt: now.subtract(const Duration(days: 4)),
      ),
    ];
  }

  static List<ActivityLogEntry> activity() {
    final now = DateTime.now();
    return [
      ActivityLogEntry(
        id: 'a1',
        actorName: 'Sarah Achieng',
        message: 'marked "Rotate Service Account Credentials" as completed.',
        timestamp: now.subtract(const Duration(days: 5)),
      ),
      ActivityLogEntry(
        id: 'a2',
        actorName: 'System',
        message: 'escalated T-102 from Medium to High priority.',
        timestamp: now.subtract(const Duration(hours: 5)),
      ),
      ActivityLogEntry(
        id: 'a3',
        actorName: 'Stephanie Uwera',
        message:
            'added a note on "Refactor Auth Service Logic": initial audit '
            'of VPC security groups completed.',
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
    ];
  }
}
