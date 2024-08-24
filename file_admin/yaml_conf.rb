# frozen_string_literal: true
#
#  Copyright 2012,2024 agwlvssainokuni
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

require_relative 'logger'
require_relative 'foreach_archive'
require_relative 'aggregate_archive'
require_relative 'backup_file'
require_relative 'backup_file_alt'
require_relative 'cleanup_file'
require_relative 'cleanup_file_alt'
require_relative 'fetch_file'
require_relative 'push_file'

FOREACH = FileAdmin::ForeachArchive
AGGREGATE = FileAdmin::AggregateArchive
BACKUP = FileAdmin::BackupFile
BACKUPALT = FileAdmin::BackupFileAlt
CLEANUP = FileAdmin::CleanupFile
CLEANUPALT = FileAdmin::CleanupFileAlt
FETCH = FileAdmin::FetchFile
PUSH = FileAdmin::PushFile
