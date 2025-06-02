-- Copyright 2022 Google LLC
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     https://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
SELECT
    campaign.id AS campaign_id,
    campaign.name AS campaign_name,
    campaign.status AS campaign_status,
    campaign.bidding_strategy_type AS bidding_strategy,
    ad_group.name AS ad_group_name,
    ad_group_ad.ad.id AS ad_id,
    ad_group_ad.ad.type AS ad_group_ad_type,
    ad_group_ad.ad.name AS ad_name,
    video.id AS youtube_video_id,
    video.title AS youtube_title,
    video.duration_millis AS youtube_video_duration
FROM video
WHERE ad_group_ad.ad.type IN (
    VIDEO_AD,
    VIDEO_BUMPER_AD,
    VIDEO_NON_SKIPPABLE_IN_STREAM_AD,
    VIDEO_RESPONSIVE_AD,
    VIDEO_TRUEVIEW_IN_STREAM_AD
	)
    AND campaign.bidding_strategy_type IN (
	"MAXIMIZE_CONVERSIONS",
	"TARGET_CPA"
    )
